# Structured Context

A `Context` is a list of named fields that can be attached to every log message within a scope.

```idris
import Log4Types

main : IO ()
main = do
  let ctx = addStr "service" "api" $ addInt "port" 8080 emptyContext
  let logger = withContext ctx (cmap show logStringStdout)
  logger <& mkInfo "ready"
  -- fields include: service="api", port=8080
```

## Building Context

```idris
emptyContext : Context                               -- empty context
addField     : String -> LogParamValue -> Context -> Context  -- raw field
addStr       : String -> String -> Context -> Context         -- string field
addInt       : String -> Integer -> Context -> Context        -- integer field
addBool      : String -> Bool -> Context -> Context           -- boolean field
addNamespace : String -> Context -> Context                   -- namespace segment
```

## Nesting

Contexts compose by appending. Inner context includes all outer fields:

```idris
let outer = addStr "service" "api" emptyContext
let inner = addInt "requestId" 123 outer
let logger = withContext inner (cmap show logStringStdout)
logger <& mkInfo "handling request"
-- fields: service="api", requestId=123
```

## How withContext Works

`withContext` uses `cmap` to prepend context fields to the `fields` list of every `Msg` that passes through the logger. The context is a pure value - no mutable state involved.
