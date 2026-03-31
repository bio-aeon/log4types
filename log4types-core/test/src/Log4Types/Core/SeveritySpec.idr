module Log4Types.Core.SeveritySpec

import Data.IORef
import Evince
import Log4Types.Core
import Log4Types.Core.TestHelpers

export
severitySpec : Spec () ()
severitySpec = describe "Severity" $ do
  describe "ordering" $ do
    it "Debug < Info" (mustBeTrue $ Debug < Info)
    it "Info < Warning" (mustBeTrue $ Info < Warning)
    it "Warning < Error" (mustBeTrue $ Warning < Error)
    it "Debug is the minimum" (mustBeTrue $ Debug <= Info && Debug <= Warning && Debug <= Error)
    it "Error is the maximum" (mustBeTrue $ Error >= Debug && Error >= Info && Error >= Warning)

  describe "filterBySeverity" $ do
    itIO "passes messages at or above threshold" $ do
      ref <- newIORef []
      let getSev : (Severity, String) -> Severity
          getSev (s, _) = s
      let filtered = filterBySeverity Warning getSev (collectAction ref)
      filtered <& (Warning, "warn-msg")
      filtered <& (Error, "err-msg")
      msgs <- map reverse (readIORef ref)
      pure $ map snd msgs `mustEqual` ["warn-msg", "err-msg"]

    itIO "suppresses messages below threshold" $ do
      ref <- newIORef []
      let getSev : (Severity, String) -> Severity
          getSev (s, _) = s
      let filtered = filterBySeverity Warning getSev (collectAction ref)
      filtered <& (Debug, "debug-msg")
      filtered <& (Info, "info-msg")
      msgs <- readIORef ref
      pure $ msgs `mustEqual` the (List (Severity, String)) []
