||| Scoped structured context for enriching log messages.
|||
||| A `Context` is a list of named fields that can be attached to every
||| log message within a scope. Contexts are pure values that compose
||| by appending.
module Log4Types.Context

import Log4Types.Core
import Log4Types.Message

%default total

----------------------------------------------------------------------
-- Context type
----------------------------------------------------------------------

||| A structured context: a list of named fields.
public export
Context : Type
Context = List (String, LogParamValue)

||| The empty context.
public export
emptyContext : Context
emptyContext = []

----------------------------------------------------------------------
-- Building context
----------------------------------------------------------------------

||| Add a primitive field to a context.
public export
addField : String -> LogParamValue -> Context -> Context
addField name val ctx = ctx ++ [(name, val)]

||| Add a string field to a context.
public export
addStr : String -> String -> Context -> Context
addStr name val = addField name (StrVal val)

||| Add an integer field to a context.
public export
addInt : String -> Integer -> Context -> Context
addInt name val = addField name (IntVal val)

||| Add a boolean field to a context.
public export
addBool : String -> Bool -> Context -> Context
addBool name val = addField name (BoolVal val)

||| Add a namespace segment to a context.
|||
||| Namespaces are stored as string fields with the key "namespace".
public export
addNamespace : String -> Context -> Context
addNamespace ns = addField "namespace" (StrVal ns)

----------------------------------------------------------------------
-- Enriching log actions
----------------------------------------------------------------------

||| Enrich a Msg log action by prepending context fields to every message.
public export
withContext : Context -> LogAction m Msg -> LogAction m Msg
withContext ctx = cmap (\msg => { fields $= (ctx ++) } msg)
