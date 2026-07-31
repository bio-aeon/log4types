# Changelog

All notable changes to the log4types package family (`log4types-core`,
`log4types`, `log4types-json`, `log4types-async`) are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/2.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
While pre-1.0, breaking changes may land in minor releases - they are marked
**Breaking** below.

## [Unreleased]

## [0.5.0] - 2026-07-31

Asynchronous logging: a new `log4types-async` package moves backend I/O off
the application's critical path.

### Added

- **`log4types-async`** - `withAsyncLogger` adapts any `LogAction IO msg`
  into a channel-buffered `LogAction (Async e [])` drained by a background
  fiber, generic over the idris2-async event loop; blocking backpressure
  via `AsyncConfig`, and every enqueued message is flushed on scope exit.
  Runs on `chez`, `racket`, and `node`; not available on `refc`.

## [0.4.0] - 2026-07-11

Multi-backend support: the packages build and their test suites pass on the
`chez`, `racket`, `refc` and `node` code generators.

### Added

- Multi-backend support, enforced by a per-backend CI matrix
  (`chez`, `racket`, `refc`, `node`).

### Known issues

- On `refc`, the log4types-json test suite does not build due to an upstream
  idris2 bug (casts from `String` fail to compile).

## [0.3.0] - 2026-04-30

### Added

- Size-based file rotation: `withRotatingLogFile` writes through a rotating
  file-backed `LogAction`, renaming `app.log` to `app.log.1` and shifting
  older copies.
- `renameFile` - file rename with C and node implementations.

## [0.2.0] - 2026-04-25

### Added

- ANSI coloured console output for development: `fmtColouredSeverity`,
  `colouredTextRenderer`, `fmtColouredMsg` and the TTY-aware
  `colouredLogStdout`.

## [0.1.0] - 2026-04-19

### Added

- Initial release - structured logging for Idris 2, inspired by co-log.
- **`log4types-core`** - the algebra: `LogAction` with contravariant
  combinators and `Semigroup`/`Monoid` fan-out, `Severity` filtering,
  `LogParamValue`, the `Loggable` interface, a backend-agnostic
  `LogRenderer`, and an in-memory `TestLog`.
- **`log4types`** - application logging: structured `Msg` types, console
  IO actions, text formatting, reader-based logging (`LoggerT`), scoped
  `Context`, and file logging.
- **`log4types-json`** - JSON backend on contrib's `Language.JSON`.
