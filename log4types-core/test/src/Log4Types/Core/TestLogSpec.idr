module Log4Types.Core.TestLogSpec

import Evince
import Log4Types.Core

export
testLogSpec : Spec () ()
testLogSpec = describe "TestLog" $ do

  describe "testLogAction" $ do
    itIO "captures all logged messages" $ do
      tl <- newTestLog
      let act = testLogAction tl
      act <& "one"
      act <& "two"
      act <& "three"
      msgs <- getMessages tl
      pure $ msgs `mustEqual` ["one", "two", "three"]

    itIO "preserves message order" $ do
      (_, msgs) <- withTestLog $ \act => do
        act <& "first"
        act <& "second"
        act <& "third"
      pure $ msgs `mustEqual` ["first", "second", "third"]

  describe "getMessages" $ do
    itIO "returns empty list when nothing logged" $ do
      tl <- newTestLog {msg = String}
      msgs <- getMessages tl
      pure $ msgs `mustEqual` []

  describe "composition" $ do
    itIO "captures from both composed actions" $ do
      tl1 <- newTestLog
      tl2 <- newTestLog
      let combined = testLogAction tl1 <+> testLogAction tl2
      combined <& "shared"
      msgs1 <- getMessages tl1
      msgs2 <- getMessages tl2
      pure $ (msgs1, msgs2) `mustEqual` (["shared"], ["shared"])

  describe "withTestLog" $ do
    itIO "returns result and captured messages" $ do
      (result, msgs) <- withTestLog $ \act => do
        act <& "logged"
        pure 42
      pure $ (result, msgs) `mustEqual` (the Int 42, ["logged"])
