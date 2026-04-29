# File Rotation

Long-running processes can fill up a log file indefinitely. `withRotatingLogFile` rotates the file when it exceeds a configured size, keeping a bounded number of older copies.

```idris
import Log4Types

main : IO ()
main = do
  Right () <- withRotatingLogFile "app.log" defaultRotation $ \act => do
    act <& "first message"
    act <& "second message"
    | Left err => putStrLn "failed to open log file"
  pure ()
```

## How rotation works

When the configured byte limit is exceeded, `app.log` is renamed to `app.log.1`. Any pre-existing `app.log.1` is shifted to `app.log.2`, and so on up to `maxFiles`. Anything beyond `maxFiles` is deleted on rotation.

A fresh `app.log` is opened for the next writes.

```
maxFiles = 3, before rotation:        after rotation:

  app.log     "current"                 app.log     ""
  app.log.1   "older 1"                 app.log.1   "current"
  app.log.2   "older 2"                 app.log.2   "older 1"
                                        app.log.3   "older 2"
```

## Configuration

```idris
record RotationConfig where
  constructor MkRotationConfig
  maxBytes : Integer
  maxFiles : Nat
```

`defaultRotation` is `MkRotationConfig 10_000_000 5` (10 MB per file, 5 rotated copies kept).

Custom example:

```idris
let cfg = MkRotationConfig 1_000_000 3   -- 1 MB, keep 3 rotated files
withRotatingLogFile "app.log" cfg (\act => ...)
```

## When to use rotation

Use `withRotatingLogFile` instead of `withLogFile` when:

- The process is long-running.
- Disk space is bounded and uncontrolled growth is unacceptable.
- You want a fixed retention window, with older logs naturally aging out.

## Caveats

- **Single-writer.** Concurrent writers to the same path will race on the byte counter and on the rename. Use one logger per file path.
- **Byte counting is approximate.** The counter adds string length plus newline; multi-byte UTF-8 lines may rotate slightly past the limit.
- **Rotation is best-effort.** If a rename fails (permissions, full disk), writes continue to the current file. Rotation will retry on the next write.
- **Crash recovery.** If the process crashes between writes, the byte counter is lost. On the next start, the counter is initialised from the file's current size, so rotation still triggers correctly on the next overshoot.
