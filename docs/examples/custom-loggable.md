# Custom Loggable Instances

Implement the `Loggable` interface to control how your types render in structured logs.

```idris
import Log4Types

record User where
  constructor MkUser
  name : String
  age  : Int

Loggable User where
  logFields renderer u acc =
    renderer.addField "name" (StrVal u.name) $
    renderer.addField "age" (IntVal $ cast u.age) acc
  logShow u = u.name ++ " (age " ++ show u.age ++ ")"
```

## The Loggable Interface

```idris
interface Loggable a where
  logFields : LogRenderer r -> a -> r -> r  -- structured fields
  logShow   : a -> String                   -- human-readable display
```

`logFields` is backend-agnostic - the same implementation works with the text renderer, JSON renderer, or any custom `LogRenderer`.

`logShow` provides a human-readable representation for log messages.

## Built-in Instances

Instances are provided for: `String`, `Int`, `Integer`, `Nat`, `Double`, `Bool`, `Maybe a`, `List a`, `LogParamValue`.

## LoggedValue - Existential Wrapper

`LoggedValue` packages a value with its `Loggable` evidence for heterogeneous collections:

```idris
data LoggedValue : Type where
  MkLoggedValue : Loggable a => (val : a) -> LoggedValue
```
