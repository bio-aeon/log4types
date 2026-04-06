module Log4Types.Core.SeveritySpec

import Evince
import Log4Types.Core

getSev : (Severity, String) -> Severity
getSev (s, _) = s

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
      tl <- newTestLog
      let filtered = filterBySeverity Warning getSev (testLogAction tl)
      filtered <& (Warning, "warn-msg")
      filtered <& (Error, "err-msg")
      msgs <- getMessages tl
      pure $ map snd msgs `mustEqual` ["warn-msg", "err-msg"]

    itIO "suppresses messages below threshold" $ do
      tl <- newTestLog
      let filtered = filterBySeverity Warning getSev (testLogAction tl)
      filtered <& (Debug, "debug-msg")
      filtered <& (Info, "info-msg")
      msgs <- getMessages tl
      pure $ msgs `mustEqual` the (List (Severity, String)) []
