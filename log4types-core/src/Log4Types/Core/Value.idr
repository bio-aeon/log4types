||| Typed primitive values for structured log fields.
|||
||| `LogParamValue` preserves type fidelity so that numbers remain
||| numbers and booleans remain booleans in structured output (e.g. JSON),
||| rather than everything being stringified.
module Log4Types.Core.Value

%default total

||| A primitive value that can appear in a structured log field.
public export
data LogParamValue
  = StrVal String
  | IntVal Integer
  | FloatVal Double
  | BoolVal Bool
  | NullVal

public export
Eq LogParamValue where
  StrVal a   == StrVal b   = a == b
  IntVal a   == IntVal b   = a == b
  FloatVal a == FloatVal b = a == b
  BoolVal a  == BoolVal b  = a == b
  NullVal    == NullVal    = True
  _          == _          = False

public export
Show LogParamValue where
  show (StrVal s)   = show s
  show (IntVal i)   = show i
  show (FloatVal f) = show f
  show (BoolVal b)  = show b
  show NullVal      = "null"
