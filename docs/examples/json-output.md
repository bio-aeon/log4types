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

Add `log4types-json` to your `pack.toml`:

```toml
[custom.all.log4types-json]
type   = "github"
url    = "https://github.com/bio-aeon/log4types"
commit = "latest:main"
ipkg   = "log4types-json/log4types-json.ipkg"
```

And to your package's `depends`:

```
depends = log4types-json
```
