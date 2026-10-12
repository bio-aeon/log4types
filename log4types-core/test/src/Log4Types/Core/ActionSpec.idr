module Log4Types.Core.ActionSpec

import Data.List
import Data.String
import Evince
import Log4Types.Core

export
actionSpec : HasIO m => Spec m () ()
actionSpec = describe "LogAction" $ do

  describe "(<&)" $ do
    it "applies the action to the message" $ do
      (_, msgs) <- withTestLog $ \act => act <& "hello"
      msgs `mustEqual` ["hello"]

  describe "(&>)" $ do
    it "applies the action to the message" $ do
      (_, msgs) <- withTestLog $ \act => "hello" &> act
      msgs `mustEqual` ["hello"]

  describe "composition" $ do
    it "both actions execute for same message" $ do
      tl1 <- newTestLog
      tl2 <- newTestLog
      let combined = testLogAction tl1 <+> testLogAction tl2
      combined <& "msg"
      msgs1 <- getMessages tl1
      msgs2 <- getMessages tl2
      (msgs1, msgs2) `mustEqual` (["msg"], ["msg"])

    it "neutral element produces no effect" $ do
      (_, msgs) <- withTestLog $ \act => do
        (neutral <+> act) <& "left"
        (act <+> neutral) <& "right"
      msgs `mustEqual` ["left", "right"]

  describe "cmap" $ do
    it "transforms message before logging" $ do
      (_, msgs) <- withTestLog $ \act => cmap show act <& 42
      msgs `mustEqual` ["42"]

  describe "cmapM" $ do
    it "transforms message monadically" $ do
      (_, msgs) <- withTestLog $ \act =>
        cmapM (\s => pure ("enriched: " ++ s)) act <& "hello"
      msgs `mustEqual` ["enriched: hello"]

  describe "cfilter" $ do
    it "passes messages satisfying predicate" $ do
      (_, msgs) <- withTestLog $ \act => cfilter (> 0) act <& 5
      msgs `mustEqual` [5]

    it "suppresses messages failing predicate" $ do
      (_, msgs) <- withTestLog $ \act => cfilter (> 0) act <& (-3)
      msgs `mustEqual` []

  describe "cmapMaybe" $ do
    it "logs when function returns Just" $ do
      (_, msgs) <- withTestLog $ \act =>
        cmapMaybe head' act <& [1, 2, 3]
      msgs `mustEqual` [1]

    it "suppresses when function returns Nothing" $ do
      (_, msgs) <- withTestLog $ \act =>
        cmapMaybe head' act <& the (List Int) []
      msgs `mustEqual` []

  describe "divide" $ do
    it "splits message and logs both parts" $ do
      tlLens <- newTestLog
      tlUppers <- newTestLog
      let act = divide (\s => (String.length s, toUpper s))
                       (testLogAction tlLens) (testLogAction tlUppers)
      act <& "hi"
      lens <- getMessages tlLens
      uppers <- getMessages tlUppers
      (lens, uppers) `mustEqual` ([2], ["HI"])

  describe "choose" $ do
    it "routes Left to first action" $ do
      tl1 <- newTestLog
      tl2 <- newTestLog
      let act = choose id (testLogAction tl1) (testLogAction tl2)
      act <& Left "left-msg"
      msgs1 <- getMessages tl1
      msgs2 <- getMessages tl2
      (msgs1, msgs2) `mustEqual` (["left-msg"], the (List String) [])

    it "routes Right to second action" $ do
      tl1 <- newTestLog
      tl2 <- newTestLog
      let act = choose id (testLogAction tl1) (testLogAction tl2)
      act <& Right "right-msg"
      msgs1 <- getMessages tl1
      msgs2 <- getMessages tl2
      (msgs1, msgs2) `mustEqual` (the (List String) [], ["right-msg"])

  describe "hoistLogAction" $ do
    it "transforms the monadic context" $ do
      (_, msgs) <- withTestLog $ \act => hoistLogAction id act <& "hoisted"
      msgs `mustEqual` ["hoisted"]
