module Log4Types.Core.TestHelpers

import Data.IORef
import Log4Types.Core

||| A log action that appends messages to an IORef list.
export
collectAction : IORef (List a) -> LogAction IO a
collectAction ref = MkLogAction $ \msg => modifyIORef ref (msg ::)

||| Run a log action and return collected messages (in order).
export
withCollect : (LogAction IO a -> IO ()) -> IO (List a)
withCollect f = do
  ref <- newIORef []
  f (collectAction ref)
  map reverse (readIORef ref)
