# log4types Documentation

Composable logging, refined by dependent types.

## Contents

| Document | Description |
|----------|-------------|
| [Getting Started](getting-started.md) | Quick-start guide with basic examples |
| [Examples](examples/) | Detailed usage examples for each feature |
| [Architecture](architecture.md) | Package structure and core types overview |

## Example Index

| Example | What it covers |
|---------|---------------|
| [String Logging](examples/string-logging.md) | Basic `LogAction` and `<&` operator |
| [Structured Messages](examples/structured-messages.md) | `Msg`, severity, and structured fields |
| [Composing Loggers](examples/composing-loggers.md) | `Semigroup` composition and file logging |
| [LoggerT](examples/loggert.md) | Reader-based logging with `LoggerT`, `logMsg`, `withLog` |
| [Filtering](examples/filtering.md) | Severity-based filtering with `filterBySeverity` |
| [Context](examples/context.md) | Scoped structured context with `withContext` |
| [Custom Loggable](examples/custom-loggable.md) | Implementing `Loggable` for your own types |
| [Testing](examples/testing.md) | In-memory `TestLog` for test assertions |
| [JSON Output](examples/json-output.md) | JSON backend with `jsonLogStdout` |
