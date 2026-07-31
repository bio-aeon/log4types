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
    itIO "enqueued messages reach the underlying action" $ do
      msgs <- runAsyncLog $ \logger => logger <& "hello"
      pure $ msgs `mustEqual` ["hello"]

    itIO "messages arrive in the order they were enqueued" $ do
      msgs <- runAsyncLog $ \logger => do
        logger <& "one"
        logger <& "two"
        logger <& "three"
      pure $ msgs `mustEqual` ["one", "two", "three"]

  describe "flush" $ do
    itIO "all enqueued messages are drained on scope exit" $ do
      msgs <- runAsyncLog $ \logger =>
        traverse_ (\i => logger <& show i) [1..100]
      pure $ length msgs `mustEqual` 100

  describe "backpressure" $ do
    itIO "producers block when the buffer is full and all messages still arrive" $ do
      tl <- newTestLog
      syncApp $ withAsyncLogger (MkAsyncConfig 2) (testLogAction tl) $ \logger =>
        traverse_ (\i => logger <& show i) [1..50]
      msgs <- getMessages tl
      pure $ length msgs `mustEqual` 50

  describe "concurrency" $ do
    itIO "multiple producer fibers can enqueue concurrently" $ do
      tl <- newTestLog
      syncApp $ withAsyncLogger defaultAsyncConfig (testLogAction tl) $ \logger => do
        f1 <- start (traverse_ (\i => logger <& ("a" ++ show i)) [1..10])
        f2 <- start (traverse_ (\i => logger <& ("b" ++ show i)) [1..10])
        ignore (join f1)
        ignore (join f2)
      msgs <- getMessages tl
      pure $ length msgs `mustEqual` 20

  describe "sink independence" $ do
    itIO "a slow underlying action still delivers every message" $ do
      tl <- newTestLog
      let slow = MkLogAction $ \m => do usleep 1000; testLogAction tl <& m
      syncApp $ withAsyncLogger defaultAsyncConfig slow $ \logger =>
        traverse_ (\i => logger <& show i) [1..10]
      msgs <- getMessages tl
      pure $ length msgs `mustEqual` 10

  describe "error contexts" $ do
    itIO "messages logged before a failure still arrive" $ do
      tl <- newTestLog
      syncApp $ withAsyncLogger defaultAsyncConfig (testLogAction tl) $ \logger => do
        let errLogger : LogAction (Async SyncST [String]) String
            errLogger = MkLogAction $ \m => weakenErrors (logger <& m)
        handleErrors (const (pure ())) $ do
          errLogger <& "reached the error context"
          errLogger <& "about to fail"
          throw "boom"
      msgs <- getMessages tl
      pure $ msgs `mustEqual` ["reached the error context", "about to fail"]
