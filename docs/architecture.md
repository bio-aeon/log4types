# Architecture

## Package Structure

```
log4types-core             (depends only on base, contrib)
  LogAction m msg          - the fundamental logger: msg -> m ()
  Semigroup, Monoid        - compose loggers
  Contravariant            - transform message types via cmap
  cfilter, divide, choose  - filtering and routing
  Severity                 - Debug | Info | Warning | Error
  LogParamValue            - typed primitives (StrVal, IntVal, ...)
  Loggable, LogRenderer    - structured value rendering
  TestLog                  - in-memory logger for testing

log4types                  (depends on log4types-core)
  Msg, SimpleMsg           - structured message types
  logStringStdout/stderr   - IO actions
  HasLog, LoggerT          - reader-based logging
  Context                  - scoped structured fields
  File                     - file-based logging

log4types-json             (depends on log4types-core)
  jsonRenderer             - LogRenderer building JSON objects
  jsonLogStdout            - JSON log action

log4types-async            (depends on log4types-core, async)
  AsyncConfig              - buffer capacity for the worker
  withAsyncLogger          - channel-buffered LogAction drained by a fiber
```

## Layers

The design has three conceptual layers:

**Layer 1 - Core Algebra** (`log4types-core`): The `LogAction m msg` type and its
combinators. Zero dependencies beyond `base` and `contrib`. This is where
composition (`<+>`), transformation (`cmap`), filtering (`cfilter`), and routing
(`divide`, `choose`) live.

**Layer 2 - Application Logging** (`log4types`): Structured message types (`Msg`,
`SimpleMsg`), IO actions (`logStringStdout`, `logStringHandle`), reader-based
logging (`HasLog`, `LoggerT`), text formatting, structured context, and file
logging.

**Layer 3 - Backends** (`log4types-json`): Output-format-specific renderers and
log actions. The JSON backend uses `Language.JSON` from `contrib` to produce
JSON objects that preserve type fidelity (numbers stay numeric, booleans stay
boolean).

**Execution wrappers** (`log4types-async`): Orthogonal to the layers above -
`withAsyncLogger` adapts any `LogAction IO msg` into a channel-buffered
`LogAction (Async e []) msg` drained by a background fiber, generic over the
idris2-async event loop the application runs.

## Core Types

| Type | Purpose |
|------|---------|
| `LogAction m msg` | A function `msg -> m ()` wrapped in a record. The fundamental logger. |
| `Severity` | `Debug \| Info \| Warning \| Error` - ordered severity levels. |
| `LogParamValue` | `StrVal \| IntVal \| FloatVal \| BoolVal \| NullVal` - typed primitives for structured fields. |
| `Loggable a` | Interface describing how a type renders to structured log fields. |
| `LogRenderer r` | Record describing how to build structured output of type `r`. |
| `LoggedValue` | Existential wrapper packaging a value with its `Loggable` evidence. |
| `Msg` | Structured message with severity, text, and key-value fields. |
| `LoggerT msg m` | Monad transformer carrying a `LogAction` in a reader environment. |
| `Context` | A list of named `LogParamValue` fields for enriching messages. |
| `TestLog msg` | In-memory log sink for testing. |
