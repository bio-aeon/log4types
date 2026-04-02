||| Concrete IO-based logging actions.
module Log4Types.IO

import System.File
import Log4Types.Core

%default total

||| Log strings to stdout, one per line.
public export
logStringStdout : HasIO io => LogAction io String
logStringStdout = MkLogAction putStrLn

||| Log strings to stderr, one per line.
public export
logStringStderr : HasIO io => LogAction io String
logStringStderr = MkLogAction $ \msg => ignore $ fPutStrLn stderr msg

||| Log any `Show`-able value to stdout.
public export
logPrintLn : (HasIO io, Show a) => LogAction io a
logPrintLn = MkLogAction $ putStrLn . show
