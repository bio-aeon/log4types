module Log4Types.AsyncSpec

import System
import IO.Async
import IO.Async.Loop.Sync
import Log4Types.Core
import Log4Types.Async
import Evince

%default covering

runAsyncLog : (LogAction (Async SyncST []) String -> Async SyncST [] ()) -> IO (List String)
runAsyncLog body = do
  tl <- newTestLog
  syncApp $ withAsyncLogger defaultAsyncConfig (testLogAction tl) body
  getMessages tl

export
asyncSpec : HasIO m => Spec m () ()
asyncSpec = describe "Async" $ do

  describe "delivery" $ do
    it "enqueued messages reach the underlying action" $ do
      msgs <- liftIO $ runAsyncLog $ \logger => logger <& "hello"
      msgs `mustEqual` ["hello"]

    it "messages arrive in the order they were enqueued" $ do
      msgs <- liftIO $ runAsyncLog $ \logger => do
        logger <& "one"
        logger <& "two"
        logger <& "three"
      msgs `mustEqual` ["one", "two", "three"]

  describe "flush" $ do
    it "all enqueued messages are drained on scope exit" $ do
      msgs <- liftIO $ runAsyncLog $ \logger =>
        traverse_ (\i => logger <& show i) [1..100]
      length msgs `mustEqual` 100

  describe "backpressure" $ do
    it "producers block when the buffer is full and all messages still arrive" $ do
      tl <- newTestLog
      liftIO $ syncApp $ withAsyncLogger (MkAsyncConfig 2) (testLogAction tl) $ \logger =>
        traverse_ (\i => logger <& show i) [1..50]
      msgs <- getMessages tl
      length msgs `mustEqual` 50

  describe "concurrency" $ do
    it "multiple producer fibers can enqueue concurrently" $ do
      msgs <- liftIO $ runAsyncLog $ \logger => do
        f1 <- start (traverse_ (\i => logger <& ("a" ++ show i)) [1..10])
        f2 <- start (traverse_ (\i => logger <& ("b" ++ show i)) [1..10])
        ignore (join f1)
        ignore (join f2)
      length msgs `mustEqual` 20

  describe "sink independence" $ do
    it "a slow underlying action still delivers every message" $ do
      tl <- newTestLog
      let slow = MkLogAction $ \m => do usleep 1000; testLogAction tl <& m
      liftIO $ syncApp $ withAsyncLogger defaultAsyncConfig slow $ \logger =>
        traverse_ (\i => logger <& show i) [1..10]
      msgs <- getMessages tl
      length msgs `mustEqual` 10

  describe "error contexts" $ do
    it "messages logged before a failure still arrive" $ do
      msgs <- liftIO $ runAsyncLog $ \logger => do
        let errLogger : LogAction (Async SyncST [String]) String
            errLogger = MkLogAction $ \m => weakenErrors (logger <& m)
        handleErrors (const (pure ())) $ do
          errLogger <& "reached the error context"
          errLogger <& "about to fail"
          throw "boom"
      msgs `mustEqual` ["reached the error context", "about to fail"]
