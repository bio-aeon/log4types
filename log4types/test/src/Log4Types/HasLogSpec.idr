module Log4Types.HasLogSpec

import Data.IORef
import Evince
import Log4Types

runCollecting : LoggerT String IO () -> IO (List String)
runCollecting body = do
  tl <- newTestLog
  usingLoggerT (testLogAction tl) body
  getMessages tl

export
hasLogSpec : Spec () ()
hasLogSpec = describe "HasLog" $ do

  describe "LogAction identity instance" $ do
    itIO "getLogAction returns self" $ do
      tl <- newTestLog
      let act : LogAction IO String = testLogAction tl
      getLogAction act <& "test"
      msgs <- getMessages tl
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
      tl <- newTestLog
      usingLoggerT (testLogAction tl) $ do
        lift (modifyIORef tl.messages ("lifted" ::))
        logMsg "logged"
      msgs <- getMessages tl
      pure $ msgs `mustEqual` ["lifted", "logged"]
