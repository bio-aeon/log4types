||| Backend-agnostic log rendering.
|||
||| A `LogRenderer` describes how to build structured output of type `r`
||| from log fields. Different backends (text, JSON, key-value pairs)
||| provide different `LogRenderer` implementations. A single `Loggable`
||| instance works with any renderer.
module Log4Types.Core.Renderer

import Log4Types.Core.Value

%default total

||| A backend-agnostic renderer for structured log output.
|||
||| This is a record (not an interface) so multiple renderers can coexist
||| in the same program without orphan instance issues.
public export
record LogRenderer (r : Type) where
  constructor MkLogRenderer
  ||| Add a named field with a primitive value.
  addField  : String -> LogParamValue -> r -> r
  ||| Add a named nested object (the function builds the nested content).
  addNested : String -> (r -> r) -> r -> r
  ||| The empty output (identity for `combine`).
  empty     : r
  ||| Merge two outputs.
  combine   : r -> r -> r
