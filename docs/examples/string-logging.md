# String Logging

The simplest way to use log4types - log strings to stdout.

```idris
import Log4Types

main : IO ()
main = do
  let logger = logStringStdout
  logger <& "Hello from log4types!"
```

`logStringStdout` is a `LogAction IO String` - it writes strings to stdout, one per line. The `<&` operator executes the action.

## Logging to stderr

```idris
logStringStderr <& "error output"
```

## Logging Show-able values

```idris
logPrintLn <& the Int 42
-- Output: 42
```
