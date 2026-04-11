# Testing with TestLog

`TestLog` captures log messages in memory so tests can assert on what was logged.

```idris
import Log4Types

testExample : IO ()
testExample = do
  tl <- newTestLog
  let logger = testLogAction tl
  logger <& "first"
  logger <& "second"
  msgs <- getMessages tl
  -- msgs == ["first", "second"]
```

## API

```idris
newTestLog    : HasIO io => io (TestLog msg)                           -- create empty
testLogAction : HasIO io => TestLog msg -> LogAction io msg            -- get a log action
getMessages   : HasIO io => TestLog msg -> io (List msg)               -- retrieve in order
withTestLog   : HasIO io => (LogAction io msg -> io a) -> io (a, List msg)  -- all-in-one
```

## Using withTestLog

`withTestLog` creates a `TestLog`, passes its action to your callback, and returns both the result and captured messages:

```idris
(result, msgs) <- withTestLog $ \logger => do
  logger <& "logged"
  pure 42
-- result == 42, msgs == ["logged"]
```

## Composing Test Loggers

`TestLog` works with all `LogAction` combinators:

```idris
tl1 <- newTestLog
tl2 <- newTestLog
let combined = testLogAction tl1 <+> testLogAction tl2
combined <& "shared"
-- both tl1 and tl2 capture "shared"
```
