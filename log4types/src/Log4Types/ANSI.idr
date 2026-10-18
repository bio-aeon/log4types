||| ANSI-coloured console output for log4types.
|||
||| Severity-coloured bracketed tags and coloured `key=value` text for
||| development-time console logging. Colour codes are emitted only when
||| stdout is a terminal; redirected output stays plain.
module Log4Types.ANSI

import Data.String
import System.File
import public Control.ANSI
import Log4Types.Core
import Log4Types.Format
import Log4Types.IO
import Log4Types.Message

%default total

||| Pick an ANSI colour for a severity level.
|||
||| Debug is green, Info blue, Warning yellow, Error red - matching the
||| conventions used by most CLI tools.
public export
severityColor : Severity -> Color
severityColor Debug   = Green
severityColor Info    = Blue
severityColor Warning = Yellow
severityColor Error   = Red

||| Format a severity as a coloured bracketed tag.
|||
||| The output is the same bracketed text as `fmtSeverity` (e.g. `[ERROR]`)
||| wrapped in ANSI escape sequences for the matching colour.
public export
fmtColouredSeverity : Severity -> String
fmtColouredSeverity sev = show $ colored (severityColor sev) (fmtSeverity sev)

||| Render fields as `fmtFields` does, except a top-level "severity" field
||| naming a severity level, which renders as its coloured bracketed tag.
public export
fmtColouredFields : List (String, LogParamValue) -> String
fmtColouredFields = unwords . map fmtColouredField
  where
    fmtColouredField : (String, LogParamValue) -> String
    fmtColouredField ("severity", StrVal "Debug")   = fmtColouredSeverity Debug
    fmtColouredField ("severity", StrVal "Info")    = fmtColouredSeverity Info
    fmtColouredField ("severity", StrVal "Warning") = fmtColouredSeverity Warning
    fmtColouredField ("severity", StrVal "Error")   = fmtColouredSeverity Error
    fmtColouredField field                          = fmtFields [field]

||| True when stdout is connected to a terminal.
|||
||| Used to decide whether ANSI colour codes should be emitted. When the
||| output is redirected to a file or pipe, colours are suppressed.
export
stdoutIsTTY : HasIO io => io Bool
stdoutIsTTY = isTTY stdout

||| Render a Msg as a single line: coloured severity tag, message text,
||| and any structured fields as `key=value` pairs.
public export
fmtColouredMsg : Msg -> String
fmtColouredMsg = fmtMsgWith fmtColouredSeverity

||| Pick a Msg formatter based on TTY availability.
|||
||| When `True`, returns the coloured formatter `fmtColouredMsg`.
||| When `False`, falls back to plain `show` so redirected output stays clean.
public export
fmtMsgForTTY : (isTTY : Bool) -> Msg -> String
fmtMsgForTTY True  = fmtColouredMsg
fmtMsgForTTY False = show

||| A log action that writes Msg values to stdout with ANSI colouring
||| when stdout is a terminal, and plain text otherwise.
export
colouredLogStdout : HasIO io => io (LogAction io Msg)
colouredLogStdout = do
  tty <- stdoutIsTTY
  pure $ cmap (fmtMsgForTTY tty) logStringStdout
