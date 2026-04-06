||| In-memory logging for testing.
|||
||| `TestLog` captures log messages in an `IORef` so tests can assert
||| on what was logged without IO side effects like writing to stdout.
module Log4Types.Core.TestLog

import Data.IORef
import Log4Types.Core.Action

%default total

||| An in-memory log sink that accumulates messages.
public export
record TestLog (msg : Type) where
  constructor MkTestLog
  messages : IORef (List msg)

||| Create a new empty TestLog.
public export
newTestLog : HasIO io => io (TestLog msg)
newTestLog = MkTestLog <$> newIORef []

||| Retrieve captured messages in the order they were logged.
public export
getMessages : HasIO io => TestLog msg -> io (List msg)
getMessages tl = reverse <$> readIORef tl.messages

||| A LogAction that appends messages to a TestLog.
public export
testLogAction : HasIO io => TestLog msg -> LogAction io msg
testLogAction tl = MkLogAction $ \msg => modifyIORef tl.messages (msg ::)

||| Create a TestLog, run an action with it, and return captured messages.
public export
withTestLog : HasIO io => (LogAction io msg -> io a) -> io (a, List msg)
withTestLog f = do
  tl <- newTestLog
  result <- f (testLogAction tl)
  msgs <- getMessages tl
  pure (result, msgs)
