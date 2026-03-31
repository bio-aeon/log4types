||| Log severity levels and severity-based filtering.
module Log4Types.Core.Severity

import Log4Types.Core.Action

%default total

----------------------------------------------------------------------
-- Severity
----------------------------------------------------------------------

||| Standard severity levels for log messages.
|||
||| Ordered from least to most severe: Debug < Info < Warning < Error.
public export
data Severity = Debug | Info | Warning | Error

public export
Eq Severity where
  Debug   == Debug   = True
  Info    == Info    = True
  Warning == Warning = True
  Error   == Error   = True
  _       == _       = False

public export
Ord Severity where
  compare x y = compare (toNat x) (toNat y)
    where
      toNat : Severity -> Nat
      toNat Debug   = 0
      toNat Info    = 1
      toNat Warning = 2
      toNat Error   = 3

public export
Show Severity where
  show Debug   = "Debug"
  show Info    = "Info"
  show Warning = "Warning"
  show Error   = "Error"

----------------------------------------------------------------------
-- Filtering
----------------------------------------------------------------------

||| Only log messages with severity at or above the given threshold.
public export
filterBySeverity : Applicative m
                => Severity
                -> (a -> Severity)
                -> LogAction m a
                -> LogAction m a
filterBySeverity threshold getSev = cfilter (\a => getSev a >= threshold)
