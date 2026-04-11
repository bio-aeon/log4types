# Reader-Based Logging with LoggerT

`LoggerT` is a monad transformer that carries a `LogAction` in a reader environment. Functions use `logMsg` to log without explicitly passing the logger around.

```idris
import Log4Types

app : LoggerT String IO ()
app = do
  logMsg "starting"
  withLog (cmap ("app: " ++)) $ do
    logMsg "inner message"  -- logged as "app: inner message"
  logMsg "done"

main : IO ()
main = usingLoggerT logStringStdout app
```

## Key Functions

**`logMsg`** - log a message by extracting the action from the reader environment:
```idris
logMsg : Monad m => MonadReader env m => HasLog env msg m => msg -> m ()
```

**`withLog`** - temporarily modify the logger for a scope:
```idris
withLog : Monad m => MonadReader env m => HasLog env msg m
       => (LogAction m msg -> LogAction m msg) -> m a -> m a
```

**`usingLoggerT`** - run a `LoggerT` computation with a concrete `LogAction`:
```idris
usingLoggerT : Monad m => LogAction m msg -> LoggerT msg m a -> m a
```

## Using logMsg and withLog Generally

`logMsg` and `withLog` are not tied to `LoggerT` - they work with any monad that satisfies `MonadReader env m` and `HasLog env msg m`. `LoggerT` is just one convenient way to provide those instances.

## Lifting Inner Monad Actions

Use `lift` to run inner-monad actions inside `LoggerT`:

```idris
app : LoggerT String IO ()
app = do
  logMsg "before IO"
  lift $ putStrLn "direct IO action"
  logMsg "after IO"
```
