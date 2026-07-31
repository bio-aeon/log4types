||| Asynchronous logging: a background fiber drains a bounded channel
||| and runs the underlying `LogAction` off the application's critical
||| path, so a log call costs a channel write instead of backend IO.
module Log4Types.Async

import IO.Async
import IO.Async.Channel
import Log4Types.Core

%default total

||| Configuration for the background log worker.
public export
record AsyncConfig where
  constructor MkAsyncConfig
  ||| Maximum messages buffered in the channel. When full, log calls
  ||| block the calling fiber until the worker catches up.
  capacity : Nat

||| Sensible default: a 1024-message buffer.
public export
defaultAsyncConfig : AsyncConfig
defaultAsyncConfig = MkAsyncConfig 1024

covering
drain : LogAction IO msg -> Channel msg -> Async e [] ()
drain underlying chan = do
  Just m <- receive chan
    | Nothing => pure ()
  liftIO (underlying <& m)
  drain underlying chan

||| Run a computation with an async-backed `LogAction`.
|||
||| A background fiber drains a bounded channel and runs `underlying`
||| on each message. The `LogAction` handed to the continuation
||| enqueues in roughly constant time, blocking only when the channel
||| is full. On scope exit the channel is closed and every pending
||| message is flushed before returning.
export covering
withAsyncLogger
  :  (config     : AsyncConfig)
  -> (underlying : LogAction IO msg)
  -> (LogAction (Async e []) msg -> Async e [] a)
  -> Async e [] a
withAsyncLogger config underlying k = do
  chan <- channel config.capacity
  fib  <- start (drain underlying chan)
  res  <- k (MkLogAction $ \m => ignore (send chan m))
  close chan
  ignore (join fib)
  pure res
