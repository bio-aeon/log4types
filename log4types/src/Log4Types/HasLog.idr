||| Typeclass-based access to loggers from an environment.
|||
||| `HasLog` provides a uniform way to extract and modify a `LogAction`
||| within an environment type. Combined with `MonadReader`, this enables
||| logging that is polymorphic over the monad - the concrete logger
||| is determined by the environment.
|||
||| `LoggerT` is a monad transformer that carries a `LogAction` in a
||| reader environment. Use `usingLoggerT` to run a `LoggerT` computation
||| with a concrete `LogAction`.
module Log4Types.HasLog

import public Control.Monad.Reader.Interface
import Control.Monad.Reader.Reader
import public Control.Monad.Trans
import Log4Types.Core

%default total

----------------------------------------------------------------------
-- HasLog interface
----------------------------------------------------------------------

||| Interface for environment types that contain a LogAction.
|||
||| The `m` parameter is the monad of the stored LogAction and should
||| match the monad you're running in. This allows `logMsg` to directly
||| execute the action without lifting.
public export
interface HasLog env msg (0 m : Type -> Type) where
  ||| Extract the LogAction from the environment.
  getLogAction : env -> LogAction m msg
  ||| Replace the LogAction in the environment.
  setLogAction : LogAction m msg -> env -> env

||| A LogAction is its own environment.
public export
HasLog (LogAction m msg) msg m where
  getLogAction = id
  setLogAction = const

----------------------------------------------------------------------
-- Logging functions
----------------------------------------------------------------------

||| Log a message by extracting the action from the reader environment.
public export
logMsg : Monad m => MonadReader env m => HasLog env msg m => msg -> m ()
logMsg msg = do
  env <- ask
  unLogAction (getLogAction env) msg

||| Run a computation with a locally modified logger.
public export
withLog : Monad m => MonadReader env m => HasLog env msg m
       => (LogAction m msg -> LogAction m msg)
       -> m a -> m a
withLog f = local (\env => setLogAction (f (getLogAction env)) env)

----------------------------------------------------------------------
-- LoggerT
----------------------------------------------------------------------

||| A monad transformer that carries a `LogAction` in a reader environment.
|||
||| The stored `LogAction` is self-referential: it operates in `LoggerT msg m`,
||| not in the inner monad `m`. This allows the action itself to use the
||| full `LoggerT` capabilities.
|||
||| Use `usingLoggerT` to run a `LoggerT` computation.
public export
record LoggerT (msg : Type) (m : Type -> Type) (a : Type) where
  constructor MkLoggerT
  unLoggerT : ReaderT (LogAction (LoggerT msg m) msg) m a

public export
Functor m => Functor (LoggerT msg m) where
  map f (MkLoggerT r) = MkLoggerT (map f r)

public export
Applicative m => Applicative (LoggerT msg m) where
  pure x = MkLoggerT (pure x)
  MkLoggerT f <*> MkLoggerT x = MkLoggerT (f <*> x)

public export
Monad m => Monad (LoggerT msg m) where
  MkLoggerT m >>= f = MkLoggerT (m >>= unLoggerT . f)

public export
MonadTrans (LoggerT msg) where
  lift = MkLoggerT . lift

public export
HasIO m => HasIO (LoggerT msg m) where
  liftIO = MkLoggerT . liftIO

public export
Monad m => MonadReader (LogAction (LoggerT msg m) msg) (LoggerT msg m) where
  ask = MkLoggerT ask
  local f (MkLoggerT m) = MkLoggerT (local f m)

||| Run a `LoggerT` computation with a concrete `LogAction`.
|||
||| The provided `LogAction m msg` (operating in the inner monad) is
||| lifted to `LogAction (LoggerT msg m) msg` via `lift`.
public export
usingLoggerT : Monad m => LogAction m msg -> LoggerT msg m a -> m a
usingLoggerT act (MkLoggerT r) =
  runReaderT (hoistLogAction lift act) r
