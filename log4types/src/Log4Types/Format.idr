||| Human-readable text formatting for log output.
module Log4Types.Format

import Log4Types.Core

%default total

||| A LogRenderer that builds key=value text output.
|||
||| Fields are rendered as `key=value` pairs separated by spaces.
||| Nested objects are rendered as `key.subkey=value`.
public export
textRenderer : LogRenderer String
textRenderer = MkLogRenderer
  { addField  = \name, val, acc =>
      let field = name ++ "=" ++ show val
      in if acc == "" then field else acc ++ " " ++ field
  , addNested = \name, build, acc =>
      let nested = build ""
          prefixed = name ++ "." ++ nested
      in if acc == "" then prefixed else acc ++ " " ++ prefixed
  , empty     = ""
  , combine   = \a, b =>
      if a == "" then b
      else if b == "" then a
      else a ++ " " ++ b
  }

||| Format a severity level as a bracketed tag.
|||
||| ```idris
||| fmtSeverity Info == "[INFO]"
||| ```
public export
fmtSeverity : Severity -> String
fmtSeverity Debug   = "[DEBUG]"
fmtSeverity Info    = "[INFO]"
fmtSeverity Warning = "[WARNING]"
fmtSeverity Error   = "[ERROR]"

||| Compose a formatting function with a string log action.
|||
||| This is `cmap` specialised for the common pattern of
||| formatting a message then sending it to a string-based logger.
public export
formatWith : (msg -> String) -> LogAction m String -> LogAction m msg
formatWith = cmap
