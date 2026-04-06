module Log4Types.Core.ActionSpec

import Data.List
import Data.String
import Evince
import Log4Types.Core

export
actionSpec : Spec () ()
actionSpec = describe "LogAction" $ do

  describe "execution" $ do
    itIO "(<&) applies the action to the message" $ do
      (_, msgs) <- withTestLog $ \act => act <& "hello"
      pure $ msgs `mustEqual` ["hello"]

    itIO "(&>) applies the action to the message (flipped)" $ do
      (_, msgs) <- withTestLog $ \act => "hello" &> act
      pure $ msgs `mustEqual` ["hello"]

  describe "composition" $ do
    itIO "both actions execute for same message" $ do
      tl1 <- newTestLog
      tl2 <- newTestLog
      let combined = testLogAction tl1 <+> testLogAction tl2
      combined <& "msg"
      msgs1 <- getMessages tl1
      msgs2 <- getMessages tl2
      pure $ (msgs1, msgs2) `mustEqual` (["msg"], ["msg"])

    itIO "neutral element produces no effect" $ do
      let silent : LogAction IO String = neutral
      (_, msgs) <- withTestLog $ \_ => silent <& "ignored"
      pure $ msgs `mustEqual` the (List String) []

  describe "cmap" $ do
    itIO "transforms message before logging" $ do
      (_, msgs) <- withTestLog $ \act => cmap show act <& the Int 42
      pure $ msgs `mustEqual` ["42"]

  describe "cmapM" $ do
    itIO "transforms message monadically" $ do
      (_, msgs) <- withTestLog $ \act =>
        cmapM (\s => pure ("enriched: " ++ s)) act <& "hello"
      pure $ msgs `mustEqual` ["enriched: hello"]

  describe "cfilter" $ do
    itIO "passes messages satisfying predicate" $ do
      (_, msgs) <- withTestLog $ \act => cfilter (> 0) act <& the Int 5
      pure $ msgs `mustEqual` [5]

    itIO "suppresses messages failing predicate" $ do
      (_, msgs) <- withTestLog $ \act => cfilter (> 0) act <& the Int (-3)
      pure $ msgs `mustEqual` the (List Int) []

  describe "cmapMaybe" $ do
    itIO "logs when function returns Just" $ do
      (_, msgs) <- withTestLog $ \act =>
        cmapMaybe Data.List.head' act <& the (List Int) [1, 2, 3]
      pure $ msgs `mustEqual` [1]

    itIO "suppresses when function returns Nothing" $ do
      (_, msgs) <- withTestLog $ \act =>
        cmapMaybe Data.List.head' act <& the (List Int) []
      pure $ msgs `mustEqual` the (List Int) []

  describe "divide" $ do
    itIO "splits message and logs both parts" $ do
      tlLens <- newTestLog
      tlUppers <- newTestLog
      let act = divide (\s => (String.length s, toUpper s))
                       (testLogAction tlLens) (testLogAction tlUppers)
      act <& "hi"
      lens <- getMessages tlLens
      uppers <- getMessages tlUppers
      pure $ (lens, uppers) `mustEqual` ([2], ["HI"])

  describe "choose" $ do
    itIO "routes Left to first action" $ do
      tl1 <- newTestLog
      tl2 <- newTestLog
      let act = choose id (testLogAction tl1) (testLogAction tl2)
      act <& Left "left-msg"
      msgs1 <- getMessages tl1
      msgs2 <- getMessages tl2
      pure $ (msgs1, msgs2) `mustEqual` (["left-msg"], the (List String) [])

    itIO "routes Right to second action" $ do
      tl1 <- newTestLog
      tl2 <- newTestLog
      let act = choose id (testLogAction tl1) (testLogAction tl2)
      act <& Right "right-msg"
      msgs1 <- getMessages tl1
      msgs2 <- getMessages tl2
      pure $ (msgs1, msgs2) `mustEqual` (the (List String) [], ["right-msg"])

  describe "hoistLogAction" $ do
    itIO "transforms the monadic context" $ do
      (_, msgs) <- withTestLog $ \act => hoistLogAction id act <& "hoisted"
      pure $ msgs `mustEqual` ["hoisted"]
