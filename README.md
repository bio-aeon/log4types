# log4types

*Composable logging, refined by dependent types.*

A structured logging library for Idris 2, inspired by Haskell's
[co-log](https://github.com/co-log/co-log) architecture.

> **Note:** log4types is experimental. The API may change between versions.

## Installation

log4types is available in the [pack](https://github.com/stefan-hoeck/idris2-pack)
package collection. Add `log4types` to your package's `depends`:

```
depends = log4types
```

For JSON support, add `log4types-json` - see [JSON Output](docs/examples/json-output.md).

## Quick Start

```idris
import Log4Types

main : IO ()
main = do
  let logger = logStringStdout
  logger <& "Hello from log4types!"
```

## Packages

| Package | Description | Dependencies |
|---------|-------------|--------------|
| `log4types-core` | Core algebra: `LogAction`, combinators, severity, structured values | `base`, `contrib` |
| `log4types` | Application logging: messages, IO actions, formatting, context | `log4types-core` |
| `log4types-json` | JSON backend for structured log output | `log4types-core` |

## Documentation

| Topic | Description |
|-------|-------------|
| [Getting Started](docs/getting-started.md) | Installation and first logger |
| [String Logging](docs/examples/string-logging.md) | Basic `LogAction` and `<&` operator |
| [Structured Messages](docs/examples/structured-messages.md) | `Msg`, severity, and fields |
| [Composing Loggers](docs/examples/composing-loggers.md) | Fan-out, `cmap`, `divide`, `choose` |
| [LoggerT](docs/examples/loggert.md) | Reader-based logging with `logMsg` and `withLog` |
| [Filtering](docs/examples/filtering.md) | Severity filtering, `cfilter`, `cmapMaybe` |
| [Context](docs/examples/context.md) | Scoped structured context |
| [Custom Loggable](docs/examples/custom-loggable.md) | Implementing `Loggable` for your types |
| [Testing](docs/examples/testing.md) | In-memory `TestLog` for assertions |
| [JSON Output](docs/examples/json-output.md) | JSON backend |
| [File Rotation](docs/examples/file-rotation.md) | Size-based rotation with `withRotatingLogFile` |
| [Architecture](docs/architecture.md) | Package structure and core types |
