# Async Logging

A synchronous log call pays the backend's I/O cost on the calling thread. `withAsyncLogger` (from `log4types-async`) moves that cost off the critical path: log calls enqueue to a bounded channel in roughly constant time, and a background fiber drains the channel into the underlying `LogAction`.

```idris
import IO.Async
import IO.Async.Loop.Sync
import Log4Types
import Log4Types.Async

main : IO ()
main = syncApp $
  withAsyncLogger defaultAsyncConfig logStringStdout $ \logger => do
    logger <& "work started"
    logger <& "work finished"
```

## How it works

`withAsyncLogger` creates a bounded channel, starts a worker fiber that drains it into the underlying `LogAction IO msg`, and hands the continuation a `LogAction (Async e []) msg` that enqueues. On scope exit the channel is closed and every pending message is flushed before `withAsyncLogger` returns - nothing enqueued inside the scope is lost.

Messages are delivered in enqueue order. A single worker per logger keeps ordering trivial.

## Configuration

```idris
record AsyncConfig where
  constructor MkAsyncConfig
  capacity : Nat
```

`defaultAsyncConfig` buffers 1024 messages. When the buffer is full, a log call blocks the calling fiber until the worker catches up - backpressure rather than message loss.

## Choosing the event loop

`withAsyncLogger` is generic over the event-loop type `e`: it runs inside whatever loop your application already uses.

- `syncApp` (from `async`, module `IO.Async.Loop.Sync`) - chez and racket.
- `app` (from `async-js`, module `IO.Async.JS`) - node.

`log4types-async` is not available on the refc backend: idris2-async's internals have no refc implementation.

## Error-carrying code

The logger's actions run in `Async e []`. Code with a non-empty error list
lifts each call with `weakenErrors` (in scope via `import IO.Async`):

```idris
let errLogger : LogAction (Async e [AppError]) Msg
    errLogger = MkLogAction $ \m => weakenErrors (logger <& m)
```

The flush guarantee is unaffected: messages enqueued before a failure are
still delivered once the errors are handled and the scope exits.

## When to use

- The sink is slow: disk writes with fsync, network collectors, rate-limited endpoints.
- Log calls sit in a hot request path where tail latency matters.

For stdout logging or short-lived tools, plain synchronous actions are simpler and fast enough.

## Caveats

- **No persistence.** Messages still in the buffer when the process crashes are lost. Keep critical audit writes synchronous.
- **Sink exceptions are not caught.** An exception in the underlying `IO` action fails the worker fiber.
- **Backpressure blocks.** A full buffer briefly blocks the logging fiber; size `capacity` for your burst profile.

## Relationship to idris2-async's own logging

idris2-async ships `IO.Async.Logging`: a leveled, string-based `Logger e` interface for `Async` applications - an interface, with no queue, worker, or structured fields. `log4types-async` is complementary: it provides the buffered background writer for any structured log4types `LogAction`. An adapter producing a `Logger e` from a `LogAction` is a possible future extension.
