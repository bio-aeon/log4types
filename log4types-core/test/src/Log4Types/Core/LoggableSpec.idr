module Log4Types.Core.LoggableSpec

import Evince
import Log4Types.Core

-- A simple renderer that collects fields as a list of (name, value) pairs
testRenderer : LogRenderer (List (String, LogParamValue))
testRenderer = MkLogRenderer
  { addField  = \name, val, acc => acc ++ [(name, val)]
  , addNested = \name, build, acc => acc ++ build []
  , empty     = []
  , combine   = (++)
  }

export
loggableSpec : Spec () ()
loggableSpec = describe "Loggable" $ do

  describe "String instance" $ do
    it "logShow returns the string" (logShow "hello" `mustEqual` "hello")
    it "logFields adds a StrVal field" $
      let fields = logFields testRenderer "hello" []
      in fields `mustEqual` [("value", StrVal "hello")]

  describe "Int instance" $ do
    it "logShow returns the number" (logShow (the Int 42) `mustEqual` "42")
    it "logFields adds an IntVal field" $
      let fields = logFields testRenderer (the Int 42) []
      in fields `mustEqual` [("value", IntVal 42)]

  describe "Bool instance" $ do
    it "logShow returns the boolean" (logShow True `mustEqual` "True")
    it "logFields adds a BoolVal field" $
      let fields = logFields testRenderer True []
      in fields `mustEqual` [("value", BoolVal True)]

  describe "Maybe instance" $ do
    it "logFields is noop for Nothing" $
      let fields = logFields testRenderer (the (Maybe Int) Nothing) []
      in fields `mustEqual` the (List (String, LogParamValue)) []

    it "logFields delegates for Just" $
      let fields = logFields testRenderer (Just (the Int 7)) []
      in fields `mustEqual` [("value", IntVal 7)]

    it "logShow shows Nothing" (logShow (the (Maybe Int) Nothing) `mustEqual` "Nothing")
    it "logShow delegates for Just" (logShow (Just (the Int 7)) `mustEqual` "7")

  describe "List instance" $ do
    it "logShow formats as bracketed list" $
      logShow [the Int 1, 2, 3] `mustEqual` "[1, 2, 3]"

  describe "LoggedValue" $ do
    it "preserves Loggable evidence through existential" $
      let lv = MkLoggedValue (the Int 42)
      in show lv `mustEqual` "42"

    it "loggedValueFields delegates to wrapped value" $
      let lv = MkLoggedValue "test"
          fields = loggedValueFields testRenderer lv []
      in fields `mustEqual` [("value", StrVal "test")]
