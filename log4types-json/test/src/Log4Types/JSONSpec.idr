module Log4Types.JSONSpec

import Language.JSON
import Evince
import Log4Types.Core
import Log4Types.JSON

export
jsonSpec : Spec () ()
jsonSpec = describe "JSON" $ do

  describe "jsonRenderer" $ do
    it "produces a JObject from addField" $
      let r = jsonRenderer.addField "key" (StrVal "val") (JObject [])
      in r `mustEqual` JObject [("key", JString "val")]

    it "accumulates multiple fields" $
      let r = jsonRenderer.addField "b" (IntVal 2) $
              jsonRenderer.addField "a" (IntVal 1) (JObject [])
      in r `mustEqual` JObject [("a", JNumber 1.0), ("b", JNumber 2.0)]

    it "combines two objects" $
      let a = JObject [("x", JNumber 1.0)]
          b = JObject [("y", JNumber 2.0)]
      in jsonRenderer.combine a b `mustEqual` JObject [("x", JNumber 1.0), ("y", JNumber 2.0)]

  describe "paramValueToJSON" $ do
    it "strings become JString" (paramValueToJSON (StrVal "hi") `mustEqual` JString "hi")
    it "integers become JNumber" (paramValueToJSON (IntVal 42) `mustEqual` JNumber 42.0)
    it "booleans become JBoolean" (paramValueToJSON (BoolVal True) `mustEqual` JBoolean True)
    it "null becomes JNull" (paramValueToJSON NullVal `mustEqual` JNull)

  describe "encodeLoggable" $ do
    it "encodes a String as JSON object" $
      encodeLoggable "hello" `mustEqual` JObject [("value", JString "hello")]

    it "encodes an Int as JSON object" $
      encodeLoggable (the Int 7) `mustEqual` JObject [("value", JNumber 7.0)]

  describe "encodeLoggableStr" $ do
    it "produces a JSON string" $
      encodeLoggableStr "test" `mustEqual` "{\"value\":\"test\"}"

    it "integers remain numeric (not quoted)" $
      encodeLoggableStr (the Int 99) `mustEqual` "{\"value\":99.0}"

    it "booleans remain boolean" $
      encodeLoggableStr True `mustEqual` "{\"value\":true}"
