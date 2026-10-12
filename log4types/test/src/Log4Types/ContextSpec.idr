module Log4Types.ContextSpec

import Evince
import Log4Types

export
contextSpec : HasIO m => Spec m () ()
contextSpec = describe "Context" $ do

  describe "addField" $ do
    it "appends field to context" $
      addField "key" (StrVal "val") emptyContext `mustEqual` [("key", StrVal "val")]

    it "preserves existing fields" $
      let ctx = addField "b" (IntVal 2) $ addField "a" (IntVal 1) emptyContext
      in ctx `mustEqual` [("a", IntVal 1), ("b", IntVal 2)]

  describe "convenience builders" $ do
    it "adds a string field" $
      addStr "name" "alice" [] `mustEqual` [("name", StrVal "alice")]

    it "adds an integer field" $
      addInt "count" 42 [] `mustEqual` [("count", IntVal 42)]

    it "adds a boolean field" $
      addBool "active" True [] `mustEqual` [("active", BoolVal True)]

    it "adds a namespace field" $
      addNamespace "auth" [] `mustEqual` [("namespace", StrVal "auth")]

  describe "withContext" $ do
    it "enriches messages with context fields" $ do
      tl <- newTestLog
      let ctx = addStr "env" "prod" emptyContext
      let act = withContext ctx (testLogAction tl)
      act <& mkInfo "hello"
      msgs <- getMessages tl
      map fields msgs `mustEqual` [[("env", StrVal "prod")]]

    it "nesting includes outer fields" $ do
      tl <- newTestLog
      let outer = addStr "service" "api" emptyContext
      let inner = addInt "requestId" 123 outer
      let act = withContext inner (testLogAction tl)
      act <& mkInfo "request"
      msgs <- getMessages tl
      map fields msgs `mustEqual`
        [[("service", StrVal "api"), ("requestId", IntVal 123)]]

    it "preserves message's own fields" $ do
      tl <- newTestLog
      let ctx = addStr "env" "prod" emptyContext
      let act = withContext ctx (testLogAction tl)
      act <& MkMsg Info "hello" [("status", IntVal 200)]
      msgs <- getMessages tl
      map fields msgs `mustEqual`
        [[("env", StrVal "prod"), ("status", IntVal 200)]]
