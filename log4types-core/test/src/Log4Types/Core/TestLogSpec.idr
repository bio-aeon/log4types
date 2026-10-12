module Log4Types.Core.TestLogSpec

import Evince
import Log4Types.Core

export
testLogSpec : HasIO m => Spec m () ()
testLogSpec = describe "TestLog" $ do

  describe "testLogAction" $ do
    it "captures all logged messages" $ do
      tl <- newTestLog
      let act = testLogAction tl
      act <& "one"
      act <& "two"
      act <& "three"
      msgs <- getMessages tl
      msgs `mustEqual` ["one", "two", "three"]

    it "preserves message order" $ do
      (_, msgs) <- withTestLog $ \act => do
        act <& "first"
        act <& "second"
        act <& "third"
      msgs `mustEqual` ["first", "second", "third"]

  describe "getMessages" $ do
    it "returns empty list when nothing logged" $ do
      tl <- newTestLog {msg = String}
      msgs <- getMessages tl
      msgs `mustEqual` []

  describe "composition" $ do
    it "captures from both composed actions" $ do
      tl1 <- newTestLog
      tl2 <- newTestLog
      let combined = testLogAction tl1 <+> testLogAction tl2
      combined <& "shared"
      msgs1 <- getMessages tl1
      msgs2 <- getMessages tl2
      (msgs1, msgs2) `mustEqual` (["shared"], ["shared"])

  describe "withTestLog" $ do
    it "returns result and captured messages" $ do
      (result, msgs) <- withTestLog $ \act => do
        act <& "logged"
        pure 42
      (result, msgs) `mustEqual` (42, ["logged"])
