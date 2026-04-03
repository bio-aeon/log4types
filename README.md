# log4types

Composable logging, refined by dependent types.

A structured logging library for Idris 2, inspired by Haskell's
[co-log](https://github.com/co-log/co-log) architecture.

## Packages

| Package | Description | Dependencies |
|---------|-------------|--------------|
| `log4types-core` | Core algebra: `LogAction`, combinators, severity, structured values | `base`, `contrib` |
| `log4types` | Application logging: messages, IO actions, formatting, context | `log4types-core` |
| `log4types-json` | JSON backend for structured log output | `log4types-core` |

## Quick Start

```idris
import Log4Types

main : IO ()
main = do
  let logger = logStringStdout
  logger <& "Hello from log4types!"
```

## Install

Requires [idris2-pack](https://github.com/stefan-hoeck/idris2-pack).

```sh
pack install log4types
```
