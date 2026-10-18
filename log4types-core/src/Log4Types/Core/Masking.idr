||| Masking and hiding of sensitive values in log output.
|||
||| `Masked a` and `Hidden a` mark a value as sensitive in its type: their
||| `Loggable` instances redact or omit it, so the value cannot reach a log
||| through its instance. The wrapped value stays available through
||| `reveal`, which keeps every deliberate unmasking grep-auditable.
module Log4Types.Core.Masking

import Data.List
import Data.String
import Log4Types.Core.Value
import Log4Types.Core.Renderer
import Log4Types.Core.Loggable

%default total

||| Wrap a value to redact it in log output.
|||
||| The wrapped value remains accessible via `reveal`; only the `Loggable`
||| instance redacts it.
public export
record Masked (a : Type) where
  constructor MkMasked
  reveal : a

||| Wrap a value to omit it from log output entirely.
|||
||| The wrapped value remains accessible via `reveal`; the `Loggable`
||| instance produces no output for it.
public export
record Hidden (a : Type) where
  constructor MkHidden
  reveal : a

||| A policy describing how to render a masked value.
public export
record MaskPolicy (a : Type) where
  constructor MkMaskPolicy
  mask : a -> String

||| Default policy: render as "***", ignoring the value.
public export
defaultMask : MaskPolicy a
defaultMask = MkMaskPolicy (const "***")

maskChar : Char
maskChar = '*'

||| Policy: keep the last `n` characters and replace each earlier one with
||| "*". A value no longer than `n` is masked entirely as "***", so the
||| policy never reveals a whole value.
public export
lastN : Nat -> MaskPolicy String
lastN n = MkMaskPolicy $ \s =>
  let hidden = length s `minus` n
  in if hidden == 0
       then defaultMask.mask s
       else replicate hidden maskChar ++ substr hidden n s

||| Policy: keep the domain of an email address and replace each character
||| of its local part with "*", so "alice@example.com" renders as
||| "*****@example.com". The split is at the last "@"; a value without one
||| is masked entirely as "***".
public export
emailDomainOnly : MaskPolicy String
emailDomainOnly = MkMaskPolicy $ \s =>
  case break (== '@') (reverse (unpack s)) of
    (domain, _ :: local) => replicate (length local) maskChar ++ "@" ++ pack (reverse domain)
    (_, [])              => defaultMask.mask s

||| Renders a masked value through `defaultMask`, whatever its type.
public export
Loggable (Masked a) where
  logFields renderer m acc = renderer.addField "value" (StrVal (defaultMask.mask m.reveal)) acc
  logShow m = defaultMask.mask m.reveal

||| Renders nothing for a hidden value.
public export
Loggable (Hidden a) where
  logFields _ _ acc = acc
  logShow _ = ""

||| Add a field rendered by an explicit masking policy, for a per-field
||| policy in a hand-written instance such as the last four digits of a
||| card number.
public export
addMaskedField
  :  LogRenderer r
  -> (name : String)
  -> (policy : MaskPolicy a)
  -> a
  -> r -> r
addMaskedField renderer name policy v =
  renderer.addField name (StrVal (policy.mask v))
