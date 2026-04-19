# Getting Started

## Installation

log4types is available in the [pack](https://github.com/stefan-hoeck/idris2-pack)
package collection. Add `log4types` to your package's `depends`:

```
depends = log4types
```

For JSON support, add `log4types-json` too:

```
depends = log4types, log4types-json
```

## Your First Logger

```idris
import Log4Types

main : IO ()
main = do
  let logger = logStringStdout
  logger <& "Hello from log4types!"
```

`LogAction` is the core type - a first-class value that consumes messages. The `<&` operator executes a log action on a message.

## Next Steps

- See [Examples](examples/) for detailed usage of each feature
- See [Architecture](architecture.md) for the package structure and core types
