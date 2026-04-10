||| File-based logging actions.
module Log4Types.File

import System.File
import Log4Types.Core

%default total

||| A LogAction that writes strings to a file handle, one per line.
|||
||| File errors are silently ignored. Use this for best-effort logging
||| where a write failure should not crash the application.
public export
logStringHandle : HasIO io => File -> LogAction io String
logStringHandle h = MkLogAction $ \msg => ignore $ fPutStrLn h msg

||| Run a computation with a LogAction writing to a file in append mode.
|||
||| Opens the file, passes the log action to the callback, and closes
||| the file when done. Returns `Left` on open failure, `Right` with
||| the callback's result on success.
export
withLogFile : HasIO io
           => String
           -> (LogAction io String -> io a)
           -> io (Either FileError a)
withLogFile path f =
  withFile path Append
    (\err => pure err)
    (\h => Right <$> f (logStringHandle h))
