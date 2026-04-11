# Structured Messages

Messages can carry severity levels and typed key-value fields.

```idris
import Log4Types

main : IO ()
main = do
  let logger = cmap show logStringStdout
  logger <& mkInfo "server started"
  logger <& MkMsg Warning "disk usage high" [("percent", IntVal 92)]
```

## Message Types

**`Msg`** carries severity, text, and structured fields:

```idris
record Msg where
  constructor MkMsg
  severity : Severity
  text     : String
  fields   : List (String, LogParamValue)
```

**`SimpleMsg`** carries only severity and text (no fields):

```idris
record SimpleMsg where
  constructor MkSimpleMsg
  severity : Severity
  text     : String
```

## Convenience Constructors

```idris
mkDebug   : String -> Msg  -- severity = Debug
mkInfo    : String -> Msg  -- severity = Info
mkWarning : String -> Msg  -- severity = Warning
mkError   : String -> Msg  -- severity = Error
```

## Field Types

`LogParamValue` preserves type fidelity in structured output:

```idris
StrVal String      -- string values
IntVal Integer     -- integer values (not quoted in JSON)
FloatVal Double    -- floating-point values
BoolVal Bool       -- boolean values (not quoted in JSON)
NullVal            -- null/missing values
```
