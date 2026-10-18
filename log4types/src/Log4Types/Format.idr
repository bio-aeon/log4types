||| Human-readable text formatting for log output.
module Log4Types.Format

import Data.String
import Log4Types.Core

%default total

||| A LogRenderer that flattens a value into a list of fields.
|||
||| Fields keep the order they are added in, and every field of a nested
||| object carries the object's name as a dotted prefix, as in
||| `customer.address.city`. The list has the shape of `Msg.fields`;
||| `fmtFields` renders it as text.
public export
fieldsRenderer : LogRenderer (List (String, LogParamValue))
fieldsRenderer = MkLogRenderer
  { addField  = \name, val, acc => acc ++ [(name, val)]
  , addNested = \name, build, acc =>
      acc ++ map (\(k, v) => (name ++ "." ++ k, v)) (build [])
  , empty     = []
  , combine   = (++)
  }

||| Render fields as space-separated `key=value` pairs.
|||
||| ```idris
||| fmtFields [("user", StrVal "alice"), ("attempt", IntVal 2)] == "user=\"alice\" attempt=2"
||| ```
public export
fmtFields : List (String, LogParamValue) -> String
fmtFields = unwords . map (\(k, v) => k ++ "=" ++ show v)

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
