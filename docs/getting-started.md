# Getting Started

## Installation

Add log4types as a dependency in your `pack.toml`:

```toml
[custom.all.log4types-core]
type   = "github"
url    = "https://github.com/bio-aeon/log4types"
commit = "latest:main"
ipkg   = "log4types-core/log4types-core.ipkg"

[custom.all.log4types]
type   = "github"
url    = "https://github.com/bio-aeon/log4types"
commit = "latest:main"
ipkg   = "log4types/log4types.ipkg"
```

Then add `log4types` to your package's `depends`:

```
depends = log4types
```

For JSON support, also add `log4types-json`:

```toml
[custom.all.log4types-json]
type   = "github"
url    = "https://github.com/bio-aeon/log4types"
commit = "latest:main"
ipkg   = "log4types-json/log4types-json.ipkg"
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
