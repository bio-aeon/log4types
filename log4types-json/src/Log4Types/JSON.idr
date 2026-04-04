||| JSON backend for log4types structured logging.
|||
||| Provides a `LogRenderer` that builds `Language.JSON.JSON` values,
||| and encoding functions for producing JSON log lines from messages.
module Log4Types.JSON

import Language.JSON
import Log4Types.Core

%default total

----------------------------------------------------------------------
-- JSON Renderer
----------------------------------------------------------------------

||| A LogRenderer that builds JSON objects.
|||
||| Fields are accumulated as key-value pairs in a `JObject`.
||| Nested objects are represented as sub-objects.
public export
jsonRenderer : LogRenderer JSON
jsonRenderer = MkLogRenderer
  { addField  = \name, val, acc => mergeField name (paramToJSON val) acc
  , addNested = \name, build, acc => mergeField name (build JNull) acc
  , empty     = JObject []
  , combine   = mergeJSON
  }
  where
    paramToJSON : LogParamValue -> JSON
    paramToJSON (StrVal s)   = JString s
    paramToJSON (IntVal i)   = JNumber (cast i)
    paramToJSON (FloatVal f) = JNumber f
    paramToJSON (BoolVal b)  = JBoolean b
    paramToJSON NullVal      = JNull

    mergeField : String -> JSON -> JSON -> JSON
    mergeField name val (JObject fields) = JObject (fields ++ [(name, val)])
    mergeField name val _                = JObject [(name, val)]

    mergeJSON : JSON -> JSON -> JSON
    mergeJSON (JObject xs) (JObject ys) = JObject (xs ++ ys)
    mergeJSON (JObject xs) _            = JObject xs
    mergeJSON _            (JObject ys) = JObject ys
    mergeJSON _            _            = JObject []

----------------------------------------------------------------------
-- Encoding
----------------------------------------------------------------------

||| Convert a LogParamValue to a JSON value.
public export
paramValueToJSON : LogParamValue -> JSON
paramValueToJSON (StrVal s)   = JString s
paramValueToJSON (IntVal i)   = JNumber (cast i)
paramValueToJSON (FloatVal f) = JNumber f
paramValueToJSON (BoolVal b)  = JBoolean b
paramValueToJSON NullVal      = JNull

||| Encode any Loggable value as a JSON object.
public export
encodeLoggable : Loggable a => a -> JSON
encodeLoggable val = logFields jsonRenderer val (JObject [])

||| Encode any Loggable value as a JSON string.
public export
encodeLoggableStr : Loggable a => a -> String
encodeLoggableStr = show . encodeLoggable

----------------------------------------------------------------------
-- JSON Log Action
----------------------------------------------------------------------

||| A log action that encodes Loggable values as JSON lines to stdout.
public export
jsonLogStdout : (HasIO io, Loggable a) => LogAction io a
jsonLogStdout = MkLogAction $ putStrLn . encodeLoggableStr
