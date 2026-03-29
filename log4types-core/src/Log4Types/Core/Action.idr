||| The fundamental LogAction type and combinators.
|||
||| A `LogAction m msg` is a first-class logging value: a function that
||| consumes a message of type `msg` in some monadic context `m`.
||| LogActions compose via Semigroup (fan-out to multiple destinations),
||| transform via Contravariant (adapt message types), and filter via
||| predicates.
module Log4Types.Core.Action

import Data.Contravariant

%default total

----------------------------------------------------------------------
-- Core type
----------------------------------------------------------------------

||| A logging action that consumes messages of type `msg` in context `m`.
|||
||| This is the central type of log4types. A LogAction is a first-class
||| value that can be composed, transformed, and passed around.
public export
record LogAction (m : Type -> Type) (msg : Type) where
  constructor MkLogAction
  unLogAction : msg -> m ()

----------------------------------------------------------------------
-- Execution
----------------------------------------------------------------------

public export infixl 5 <&
public export infixr 5 &>

||| Execute a log action on a message.
|||
||| ```idris
||| logStringStdout <& "hello"
||| ```
public export
(<&) : LogAction m msg -> msg -> m ()
(<&) = unLogAction

||| Execute a log action on a message (flipped).
public export
(&>) : msg -> LogAction m msg -> m ()
(&>) = flip (<&)

----------------------------------------------------------------------
-- Contravariant
----------------------------------------------------------------------

||| Transform the message type before logging.
|||
||| If you can log `b` and you have `a -> b`, you can log `a`.
public export
cmap : (a -> b) -> LogAction m b -> LogAction m a
cmap f (MkLogAction act) = MkLogAction (act . f)

public export
Contravariant (LogAction m) where
  contramap = cmap

||| Transform the message type using a monadic computation.
|||
||| Like `cmap` but the transformation can perform effects.
||| Useful for enriching messages with timestamps, thread IDs, etc.
public export
cmapM : Monad m => (a -> m b) -> LogAction m b -> LogAction m a
cmapM f (MkLogAction act) = MkLogAction (\a => f a >>= act)

----------------------------------------------------------------------
-- Composition
----------------------------------------------------------------------

||| Combine two log actions: both receive the same message.
public export
Applicative m => Semigroup (LogAction m msg) where
  MkLogAction a1 <+> MkLogAction a2 = MkLogAction $ \msg => a1 msg *> a2 msg

||| The silent log action that discards all messages.
public export
Applicative m => Monoid (LogAction m msg) where
  neutral = MkLogAction $ \_ => pure ()

----------------------------------------------------------------------
-- Filtering
----------------------------------------------------------------------

||| Only log messages satisfying a predicate.
public export
cfilter : Applicative m => (msg -> Bool) -> LogAction m msg -> LogAction m msg
cfilter p (MkLogAction act) = MkLogAction $ \msg =>
  if p msg then act msg else pure ()

||| Only log messages satisfying a monadic predicate.
public export
cfilterM : Monad m => (msg -> m Bool) -> LogAction m msg -> LogAction m msg
cfilterM p (MkLogAction act) = MkLogAction $ \msg => do
  ok <- p msg
  if ok then act msg else pure ()

||| Transform and filter: only log when the function returns Just.
public export
cmapMaybe : Applicative m => (a -> Maybe b) -> LogAction m b -> LogAction m a
cmapMaybe f (MkLogAction act) = MkLogAction $ \a =>
  case f a of
    Just b  => act b
    Nothing => pure ()

----------------------------------------------------------------------
-- Divisible
----------------------------------------------------------------------

||| Split a message into two parts and log each to a different action.
|||
||| Contravariant analogue of Applicative: if you can split `a` into
||| `(b, c)` and log each independently, you can log `a`.
public export
divide : Applicative m
      => (a -> (b, c))
      -> LogAction m b
      -> LogAction m c
      -> LogAction m a
divide f (MkLogAction actB) (MkLogAction actC) = MkLogAction $ \a =>
  let (b, c) = f a in actB b *> actC c

----------------------------------------------------------------------
-- Decidable
----------------------------------------------------------------------

||| Route a message to one of two loggers based on a decision function.
|||
||| Contravariant analogue of Alternative: if you can decide whether
||| `a` is a `b` or a `c`, and log each, you can log `a`.
public export
choose : Applicative m
      => (a -> Either b c)
      -> LogAction m b
      -> LogAction m c
      -> LogAction m a
choose f (MkLogAction actB) (MkLogAction actC) = MkLogAction $ \a =>
  case f a of
    Left  b => actB b
    Right c => actC c

----------------------------------------------------------------------
-- Monad transformation
----------------------------------------------------------------------

||| Transform the monadic context of a LogAction via a natural transformation.
public export
hoistLogAction : ({0 x : Type} -> m x -> n x) -> LogAction m a -> LogAction n a
hoistLogAction nat (MkLogAction act) = MkLogAction (nat . act)
