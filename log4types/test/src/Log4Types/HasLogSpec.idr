module Log4Types.HasLogSpec

import Data.IORef
import Evince
import Log4Types

runCollecting : HasIO io => LoggerT String io () -> io (List String)
runCollecting body = do
  tl <- newTestLog
  usingLoggerT (testLogAction tl) body
  getMessages tl

export
hasLogSpec : HasIO m => Spec m () ()
hasLogSpec = describe "HasLog" $ do

  describe "LogAction identity instance" $ do
    it "yields the action itself as the logger" $ do
      tl <- newTestLog
      let act : LogAction IO String = testLogAction tl
      liftIO $ getLogAction act <& "test"
      msgs <- getMessages tl
      msgs `mustEqual` ["test"]

  describe "logMsg" $ do
    it "extracts action from environment and applies" $ do
      msgs <- runCollecting $ logMsg "hello"
      msgs `mustEqual` ["hello"]

    it "sequences multiple log messages" $ do
      msgs <- runCollecting $ do logMsg "first"; logMsg "second"
      msgs `mustEqual` ["first", "second"]

  describe "withLog" $ do
    it "temporarily modifies the logger" $ do
      msgs <- runCollecting $ do
        logMsg "before"
        withLog (cmap ("PREFIX: " ++)) (logMsg "inner")
        logMsg "after"
      msgs `mustEqual` ["before", "PREFIX: inner", "after"]

  describe "usingLoggerT" $ do
    it "lifts inner monad actions" $ do
      tl <- newTestLog
      usingLoggerT (testLogAction tl) $ do
        lift (modifyIORef tl.messages ("lifted" ::))
        logMsg "logged"
      msgs <- getMessages tl
      msgs `mustEqual` ["lifted", "logged"]
