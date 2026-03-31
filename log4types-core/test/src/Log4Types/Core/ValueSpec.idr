module Log4Types.Core.ValueSpec

import Evince
import Log4Types.Core

export
valueSpec : Spec () ()
valueSpec = describe "LogParamValue" $ do
  it "StrVal shows quoted" (show (StrVal "hello") `mustEqual` "\"hello\"")
  it "IntVal shows number" (show (IntVal 42) `mustEqual` "42")
  it "BoolVal shows boolean" (show (BoolVal True) `mustEqual` "True")
  it "NullVal shows null" (show NullVal `mustEqual` "null")
  it "equality holds for same values" (mustBeTrue $ IntVal 1 == IntVal 1)
  it "equality fails for different values" (mustBeFalse $ IntVal 1 == IntVal 2)
  it "equality fails across constructors" (mustBeFalse $ IntVal 0 == BoolVal False)
