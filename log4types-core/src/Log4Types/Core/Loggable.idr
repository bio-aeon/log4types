||| The Loggable interface for structured log values.
|||
||| `Loggable` describes how a type renders into structured log fields,
||| independent of the output format. A single `Loggable` instance works
||| with any `LogRenderer` -- JSON, text, key-value pairs, etc.
module Log4Types.Core.Loggable

import Data.List
import Log4Types.Core.Value
import Log4Types.Core.Renderer

%default total

----------------------------------------------------------------------
-- Loggable interface
----------------------------------------------------------------------

||| Typeclass for types that can be rendered as structured log data.
|||
||| Implement `logFields` to describe how your type contributes fields
||| to a log entry, and `logShow` for human-readable display.
public export
interface Loggable a where
  ||| Render all structured fields of this value into the renderer.
  logFields : LogRenderer r -> a -> r -> r

  ||| Human-readable string representation for log messages.
  logShow : a -> String

----------------------------------------------------------------------
-- LoggedValue existential
----------------------------------------------------------------------

||| An existentially-wrapped loggable value.
|||
||| Packages a value together with its `Loggable` evidence so it can
||| be stored in heterogeneous collections and passed without carrying
||| the type parameter.
public export
data LoggedValue : Type where
  MkLoggedValue : Loggable a => (val : a) -> LoggedValue

||| Render the fields of a LoggedValue using the given renderer.
public export
loggedValueFields : LogRenderer r -> LoggedValue -> r -> r
loggedValueFields renderer (MkLoggedValue val) = logFields renderer val

||| Show a LoggedValue using its Loggable instance.
public export
loggedValueShow : LoggedValue -> String
loggedValueShow (MkLoggedValue val) = logShow val

public export
Show LoggedValue where
  show = loggedValueShow

----------------------------------------------------------------------
-- Built-in instances
----------------------------------------------------------------------

public export
Loggable String where
  logFields renderer s acc = renderer.addField "value" (StrVal s) acc
  logShow = id

public export
Loggable Int where
  logFields renderer i acc = renderer.addField "value" (IntVal $ cast i) acc
  logShow = show

public export
Loggable Integer where
  logFields renderer i acc = renderer.addField "value" (IntVal i) acc
  logShow = show

public export
Loggable Nat where
  logFields renderer n acc = renderer.addField "value" (IntVal $ cast n) acc
  logShow = show

public export
Loggable Double where
  logFields renderer d acc = renderer.addField "value" (FloatVal d) acc
  logShow = show

public export
Loggable Bool where
  logFields renderer b acc = renderer.addField "value" (BoolVal b) acc
  logShow = show

public export
Loggable a => Loggable (Maybe a) where
  logFields renderer Nothing  acc = acc
  logFields renderer (Just x) acc = logFields renderer x acc
  logShow Nothing  = "Nothing"
  logShow (Just x) = logShow x

public export
Loggable a => Loggable (List a) where
  logFields renderer xs acc = foldl (\a, x => logFields renderer x a) acc xs
  logShow xs = "[" ++ concat (intersperse ", " (map logShow xs)) ++ "]"

public export
Loggable LogParamValue where
  logFields renderer v acc = renderer.addField "value" v acc
  logShow = show
