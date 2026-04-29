||| Size-based rotation for file-backed loggers.
|||
||| `withRotatingLogFile` is a continuation-style entry point that gives
||| the user a `LogAction` writing to a file. When the file's size exceeds
||| a configured limit, the action rotates the file (renaming
||| `app.log` to `app.log.1`, shifting older files up, and deleting
||| anything beyond a count limit), then continues writing to a fresh
||| file at the original path.
module Log4Types.File.Rotation

import Data.IORef
import System.File
import System.File.Meta
import Log4Types.Core
import Log4Types.File

%default total

----------------------------------------------------------------------
-- FFI for renameFile
----------------------------------------------------------------------

%foreign "C:rename,libc 6"
         "node:lambda:(from, to) => { try { require('fs').renameSync(from, to); return 0; } catch (e) { return -1; } }"
prim__rename : (from : String) -> (to : String) -> PrimIO Int

||| Rename a file. Returns `Left` on failure (most often: source missing or
||| permission denied). The `FileError` is `GenericFileError` carrying the
||| platform's raw return code, since structured errnos are not available
||| across all backends.
export
renameFile : HasIO io => (from : String) -> (to : String) -> io (Either FileError ())
renameFile from to = do
  res <- primIO (prim__rename from to)
  if res == 0 then pure (Right ()) else pure (Left (GenericFileError res))

----------------------------------------------------------------------
-- Configuration
----------------------------------------------------------------------

||| Configuration for size-based file rotation.
public export
record RotationConfig where
  constructor MkRotationConfig
  ||| Maximum bytes in the current file before rotation triggers.
  maxBytes : Integer
  ||| Maximum number of rotated files to keep (file.1, file.2, ...).
  ||| Files beyond this are deleted after rotation.
  maxFiles : Nat

||| Default rotation: 10 MB per file, keep 5 rotated copies.
public export
defaultRotation : RotationConfig
defaultRotation = MkRotationConfig 10_000_000 5

----------------------------------------------------------------------
-- Internals
----------------------------------------------------------------------

record RotatingState where
  constructor MkRotatingState
  basePath  : String
  config    : RotationConfig
  handleRef : IORef File
  bytesRef  : IORef Integer

rotatedPath : String -> Nat -> String
rotatedPath base i = base ++ "." ++ show i

||| Rename `base.i` to `base.(i+1)` for `i` from `start` down to 1.
||| Pre-existing targets are removed first.
shiftRotated : HasIO io => (basePath : String) -> (start : Nat) -> io ()
shiftRotated _    Z     = pure ()
shiftRotated base (S k) = do
  let source = rotatedPath base (S k)
  let target = rotatedPath base (S (S k))
  ignore $ removeFile target
  ignore $ renameFile source target
  shiftRotated base k

rotate : HasIO io => RotatingState -> io ()
rotate st = do
  current <- readIORef st.handleRef
  ignore $ closeFile current
  case st.config.maxFiles of
    Z   => pure ()
    S k => shiftRotated st.basePath k
  ignore $ renameFile st.basePath (rotatedPath st.basePath 1)
  Right fresh <- openFile st.basePath WriteTruncate
    | Left _ => pure ()
  writeIORef st.handleRef fresh
  writeIORef st.bytesRef 0

rotateIfNeeded : HasIO io => RotatingState -> io ()
rotateIfNeeded st = do
  bytes <- readIORef st.bytesRef
  when (bytes >= st.config.maxBytes && st.config.maxFiles > 0) (rotate st)

writeAndCount : HasIO io => RotatingState -> String -> io ()
writeAndCount st msg = do
  current <- readIORef st.handleRef
  ignore $ fPutStrLn current msg
  ignore $ fflush current
  modifyIORef st.bytesRef (+ cast (length msg + 1))
  rotateIfNeeded st

----------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------

||| Run a computation with a rotating file-backed `LogAction`.
|||
||| Writes go to `basePath`. When size exceeds `config.maxBytes`,
||| `basePath` is renamed to `basePath.1`, previous `.1` becomes `.2`,
||| and so on up to `config.maxFiles`. Files beyond that count are
||| deleted on rotation.
|||
||| Returns `Left FileError` if the initial open failed, otherwise
||| `Right` with the callback's result.
export
withRotatingLogFile
  :  HasIO io
  => (basePath : String)
  -> (config   : RotationConfig)
  -> (LogAction io String -> io a)
  -> io (Either FileError a)
withRotatingLogFile basePath config k = do
  Right h <- openFile basePath Append
    | Left err => pure (Left err)
  initialBytes <- case !(fileSize h) of
                    Right n => pure (cast {to = Integer} n)
                    Left _  => pure 0
  hRef <- newIORef h
  bRef <- newIORef initialBytes
  let st = MkRotatingState basePath config hRef bRef
  result <- k (MkLogAction (writeAndCount st))
  finalH <- readIORef hRef
  ignore $ closeFile finalH
  pure (Right result)
