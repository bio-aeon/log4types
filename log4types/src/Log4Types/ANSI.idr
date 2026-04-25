||| ANSI-coloured console output for log4types.
|||
||| Severity-coloured bracketed tags and a coloured text renderer for
||| development-time console logging. Colour codes are emitted only when
||| stdout is a terminal; redirected output stays plain.
module Log4Types.ANSI

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

||| A LogRenderer that produces key=value text with a coloured severity tag
||| when the renderer encounters a "severity" field.
|||
||| Non-severity fields render exactly as `textRenderer` does.
public export
colouredTextRenderer : LogRenderer String
colouredTextRenderer = MkLogRenderer
  { addField  = \name, val, acc =>
      let field = if name == "severity"
                    then case val of
                           StrVal s => colourize s
                           _        => name ++ "=" ++ show val
                    else name ++ "=" ++ show val
      in if acc == "" then field else acc ++ " " ++ field
  , addNested = \name, build, acc =>
      let nested   = build ""
          prefixed = name ++ "." ++ nested
      in if acc == "" then prefixed else acc ++ " " ++ prefixed
  , empty     = ""
  , combine   = \a, b =>
      if a == "" then b
      else if b == "" then a
      else a ++ " " ++ b
  }
  where
    colourize : String -> String
    colourize "Debug"   = fmtColouredSeverity Debug
    colourize "Info"    = fmtColouredSeverity Info
    colourize "Warning" = fmtColouredSeverity Warning
    colourize "Error"   = fmtColouredSeverity Error
    colourize other     = "severity=\"" ++ other ++ "\""

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
fmtColouredMsg msg =
  let sevPart = fmtColouredSeverity msg.severity
      textPart = msg.text
      fieldsPart = foldl addFieldStr "" msg.fields
  in if fieldsPart == ""
       then sevPart ++ " " ++ textPart
       else sevPart ++ " " ++ textPart ++ " " ++ fieldsPart
  where
    addFieldStr : String -> (String, LogParamValue) -> String
    addFieldStr acc (k, v) =
      let part = k ++ "=" ++ show v
      in if acc == "" then part else acc ++ " " ++ part

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
