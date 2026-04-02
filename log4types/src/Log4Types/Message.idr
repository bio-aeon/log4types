||| Structured message types for application logging.
module Log4Types.Message

import Log4Types.Core
import Log4Types.Format

%default total

----------------------------------------------------------------------
-- SimpleMsg
----------------------------------------------------------------------

||| A simple log message with severity and text, no structured fields.
public export
record SimpleMsg where
  constructor MkSimpleMsg
  severity : Severity
  text     : String

public export
Show SimpleMsg where
  show msg = fmtSeverity msg.severity ++ " " ++ msg.text

public export
Loggable SimpleMsg where
  logFields renderer msg acc =
    renderer.addField "severity" (StrVal $ show msg.severity) $
    renderer.addField "message" (StrVal msg.text) acc
  logShow = show

----------------------------------------------------------------------
-- Msg
----------------------------------------------------------------------

||| A structured log message with severity, text, and key-value fields.
public export
record Msg where
  constructor MkMsg
  severity : Severity
  text     : String
  fields   : List (String, LogParamValue)

public export
Show Msg where
  show msg =
    let base = fmtSeverity msg.severity ++ " " ++ msg.text
        flds = concatMap (\(k, v) => " " ++ k ++ "=" ++ show v) msg.fields
    in base ++ flds

public export
Loggable Msg where
  logFields renderer msg acc =
    let acc' = renderer.addField "severity" (StrVal $ show msg.severity) $
               renderer.addField "message" (StrVal msg.text) acc
    in foldl (\a, (k, v) => renderer.addField k v a) acc' msg.fields
  logShow = show

----------------------------------------------------------------------
-- Convenience constructors
----------------------------------------------------------------------

||| Create a Debug message with no structured fields.
public export
mkDebug : String -> Msg
mkDebug t = MkMsg Debug t []

||| Create an Info message with no structured fields.
public export
mkInfo : String -> Msg
mkInfo t = MkMsg Info t []

||| Create a Warning message with no structured fields.
public export
mkWarning : String -> Msg
mkWarning t = MkMsg Warning t []

||| Create an Error message with no structured fields.
public export
mkError : String -> Msg
mkError t = MkMsg Error t []
