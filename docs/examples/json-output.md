# JSON Output

The `log4types-json` package provides a JSON backend that preserves type fidelity - integers stay numeric, booleans stay boolean.

```idris
import Log4Types.Core
import Log4Types.JSON

main : IO ()
main = do
  jsonLogStdout <& True
  -- Output: {"value":true}
```

## JSON Renderer

`jsonRenderer` is a `LogRenderer JSON` that builds `Language.JSON.JSON` objects:

```idris
jsonRenderer : LogRenderer JSON
```

Use it with `Loggable` instances to render any type as JSON:

```idris
encodeLoggable    : Loggable a => a -> JSON     -- as JSON value
encodeLoggableStr : Loggable a => a -> String   -- as JSON string
```

## Type Fidelity

`LogParamValue` constructors map to native JSON types:

| LogParamValue | JSON |
|---------------|------|
| `StrVal s` | `JString s` |
| `IntVal i` | `JNumber (cast i)` |
| `FloatVal f` | `JNumber f` |
| `BoolVal b` | `JBoolean b` |
| `NullVal` | `JNull` |

## Installation

`log4types-json` is available in the [pack](https://github.com/stefan-hoeck/idris2-pack)
package collection. Add it to your package's `depends`:

```
depends = log4types-json
```
