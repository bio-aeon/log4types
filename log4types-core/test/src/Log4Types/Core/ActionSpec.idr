module Log4Types.Core.ActionSpec

import Data.IORef
import Data.List
import Data.String
import Evince
import Log4Types.Core
import Log4Types.Core.TestHelpers

export
actionSpec : Spec () ()
actionSpec = describe "LogAction" $ do

  describe "execution" $ do
    itIO "(<&) applies the action to the message" $ do
      msgs <- withCollect $ \act => act <& "hello"
      pure $ msgs `mustEqual` ["hello"]

    itIO "(&>) applies the action to the message (flipped)" $ do
      msgs <- withCollect $ \act => "hello" &> act
      pure $ msgs `mustEqual` ["hello"]

  describe "composition" $ do
    itIO "both actions execute for same message" $ do
      ref1 <- newIORef []
      ref2 <- newIORef []
      let combined = collectAction ref1 <+> collectAction ref2
      combined <& "msg"
      msgs1 <- map reverse (readIORef ref1)
      msgs2 <- map reverse (readIORef ref2)
      pure $ (msgs1, msgs2) `mustEqual` (["msg"], ["msg"])

    itIO "neutral element produces no effect" $ do
      let silent : LogAction IO String = neutral
      msgs <- withCollect $ \_ => silent <& "ignored"
      pure $ msgs `mustEqual` the (List String) []

  describe "cmap" $ do
    itIO "transforms message before logging" $ do
      msgs <- withCollect $ \act => cmap show act <& the Int 42
      pure $ msgs `mustEqual` ["42"]

  describe "cmapM" $ do
    itIO "transforms message monadically" $ do
      msgs <- withCollect $ \act =>
        cmapM (\s => pure ("enriched: " ++ s)) act <& "hello"
      pure $ msgs `mustEqual` ["enriched: hello"]

  describe "cfilter" $ do
    itIO "passes messages satisfying predicate" $ do
      msgs <- withCollect $ \act => cfilter (> 0) act <& the Int 5
      pure $ msgs `mustEqual` [5]

    itIO "suppresses messages failing predicate" $ do
      msgs <- withCollect $ \act => cfilter (> 0) act <& the Int (-3)
      pure $ msgs `mustEqual` the (List Int) []

  describe "cmapMaybe" $ do
    itIO "logs when function returns Just" $ do
      msgs <- withCollect $ \act =>
        cmapMaybe Data.List.head' act <& the (List Int) [1, 2, 3]
      pure $ msgs `mustEqual` [1]

    itIO "suppresses when function returns Nothing" $ do
      msgs <- withCollect $ \act =>
        cmapMaybe Data.List.head' act <& the (List Int) []
      pure $ msgs `mustEqual` the (List Int) []

  describe "divide" $ do
    itIO "splits message and logs both parts" $ do
      refLens <- newIORef (the (List Nat) [])
      refUppers <- newIORef (the (List String) [])
      let act = divide (\s => (length s, toUpper s))
                       (collectAction refLens) (collectAction refUppers)
      act <& "hi"
      lens <- map reverse (readIORef refLens)
      uppers <- map reverse (readIORef refUppers)
      pure $ (lens, uppers) `mustEqual` ([2], ["HI"])

  describe "choose" $ do
    itIO "routes Left to first action" $ do
      ref1 <- newIORef (the (List String) [])
      ref2 <- newIORef (the (List String) [])
      let act = choose id (collectAction ref1) (collectAction ref2)
      act <& Left "left-msg"
      msgs1 <- map reverse (readIORef ref1)
      msgs2 <- map reverse (readIORef ref2)
      pure $ (msgs1, msgs2) `mustEqual` (["left-msg"], the (List String) [])

    itIO "routes Right to second action" $ do
      ref1 <- newIORef (the (List String) [])
      ref2 <- newIORef (the (List String) [])
      let act = choose id (collectAction ref1) (collectAction ref2)
      act <& Right "right-msg"
      msgs1 <- map reverse (readIORef ref1)
      msgs2 <- map reverse (readIORef ref2)
      pure $ (msgs1, msgs2) `mustEqual` (the (List String) [], ["right-msg"])

  describe "hoistLogAction" $ do
    itIO "transforms the monadic context" $ do
      msgs <- withCollect $ \act => hoistLogAction id act <& "hoisted"
      pure $ msgs `mustEqual` ["hoisted"]
