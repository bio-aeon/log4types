# Composing Loggers

LogActions form a `Semigroup` and `Monoid`. Composing two loggers means both receive the same message.

## Fan-out to multiple destinations

```idris
import Log4Types

main : IO ()
main = do
  Right () <- withLogFile "app.log" $ \fileAct => do
    let logger = logStringStdout <+> fileAct
    logger <& "this goes to both stdout and app.log"
    | Left err => putStrLn "failed to open log file"
```

## The silent logger

`neutral` is the identity element - a logger that discards all messages. Useful for disabling logging in specific scopes:

```idris
let silent : LogAction IO String = neutral
silent <& "this goes nowhere"
```

## Transforming message types with cmap

`cmap` (contravariant map) transforms the message type before logging. If you have a logger for `String` and a function `a -> String`, you get a logger for `a`:

```idris
let intLogger = cmap show logStringStdout
intLogger <& the Int 42
-- Output: 42
```

## Splitting messages with divide

`divide` splits a message into two parts and sends each to a different logger:

```idris
let act = divide (\s => (String.length s, toUpper s)) lenLogger upperLogger
act <& "hi"
-- lenLogger receives 2, upperLogger receives "HI"
```

## Routing with choose

`choose` routes messages to one of two loggers based on an `Either`:

```idris
let act = choose id errorLogger infoLogger
act <& Left "error!"   -- goes to errorLogger
act <& Right "all ok"  -- goes to infoLogger
```
