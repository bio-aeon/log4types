module Log4Types.HasLogSpec

import Data.IORef
import Evince
import Log4Types

collectAction : IORef (List a) -> LogAction IO a
collectAction ref = MkLogAction $ \msg => modifyIORef ref (msg ::)

runCollecting : LoggerT String IO () -> IO (List String)
runCollecting body = do
  ref <- newIORef []
  usingLoggerT (collectAction ref) body
  map reverse (readIORef ref)

export
hasLogSpec : Spec () ()
hasLogSpec = describe "HasLog" $ do

  describe "LogAction identity instance" $ do
    itIO "getLogAction returns self" $ do
      ref <- newIORef (the (List String) [])
      getLogAction (collectAction ref) <& "test"
      msgs <- map reverse (readIORef ref)
      pure $ msgs `mustEqual` ["test"]

  describe "logMsg" $ do
    itIO "extracts action from environment and applies" $ do
      msgs <- runCollecting $ logMsg "hello"
      pure $ msgs `mustEqual` ["hello"]

    itIO "sequences multiple log messages" $ do
      msgs <- runCollecting $ do logMsg "first"; logMsg "second"
      pure $ msgs `mustEqual` ["first", "second"]

  describe "withLog" $ do
    itIO "temporarily modifies the logger" $ do
      msgs <- runCollecting $ do
        logMsg "before"
        withLog (cmap ("PREFIX: " ++)) (logMsg "inner")
        logMsg "after"
      pure $ msgs `mustEqual` ["before", "PREFIX: inner", "after"]

  describe "usingLoggerT" $ do
    itIO "lifts inner monad actions" $ do
      ref <- newIORef (the (List String) [])
      usingLoggerT (collectAction ref) $ do
        lift (modifyIORef ref ("lifted" ::))
        logMsg "logged"
      msgs <- map reverse (readIORef ref)
      pure $ msgs `mustEqual` ["lifted", "logged"]
