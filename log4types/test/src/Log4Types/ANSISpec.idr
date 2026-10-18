module Log4Types.ANSISpec

import Data.String
import Evince
import Log4Types

esc : String
esc = "\ESC"

export
ansiSpec : Applicative m => Spec m () ()
ansiSpec = describe "ANSI" $ do

  describe "fmtColouredSeverity" $ do
    it "wraps DEBUG in green escape sequences" $
      mustBeTrue $ isInfixOf "[DEBUG]" (fmtColouredSeverity Debug)
          && isInfixOf esc (fmtColouredSeverity Debug)

    it "wraps INFO in blue escape sequences" $
      mustBeTrue $ isInfixOf "[INFO]" (fmtColouredSeverity Info)
          && isInfixOf esc (fmtColouredSeverity Info)

    it "wraps WARNING in yellow escape sequences" $
      mustBeTrue $ isInfixOf "[WARNING]" (fmtColouredSeverity Warning)
          && isInfixOf esc (fmtColouredSeverity Warning)

    it "wraps ERROR in red escape sequences" $
      mustBeTrue $ isInfixOf "[ERROR]" (fmtColouredSeverity Error)
          && isInfixOf esc (fmtColouredSeverity Error)

    it "ends with a reset escape sequence" $
      mustBeTrue $ isInfixOf (esc ++ "[0m") (fmtColouredSeverity Info)

  describe "severity-to-colour mapping" $ do
    it "uses Green for Debug" $
      mustBeTrue $ isInfixOf "38;5;2" (fmtColouredSeverity Debug)

    it "uses Blue for Info" $
      mustBeTrue $ isInfixOf "38;5;4" (fmtColouredSeverity Info)

    it "uses Yellow for Warning" $
      mustBeTrue $ isInfixOf "38;5;3" (fmtColouredSeverity Warning)

    it "uses Red for Error" $
      mustBeTrue $ isInfixOf "38;5;1" (fmtColouredSeverity Error)

  describe "fmtColouredFields" $ do
    it "renders each severity as its coloured tag" $
      let severities = [Debug, Info, Warning, Error]
      in fmtColouredFields (map (\s => ("severity", StrVal (show s))) severities)
           `mustEqual` unwords (map fmtColouredSeverity severities)

    it "keeps other fields plain and in order" $
      fmtColouredFields [("count", IntVal 42), ("severity", StrVal "Info")]
        `mustEqual` ("count=42 " ++ fmtColouredSeverity Info)

    it "renders an unknown severity as a plain field" $
      fmtColouredFields [("severity", StrVal "Trace")] `mustEqual` "severity=\"Trace\""

  describe "fmtColouredMsg" $ do
    it "renders its severity as a coloured tag" $
      fmtColouredMsg (mkWarning "disk low") `mustEqual` (fmtColouredSeverity Warning ++ " disk low")

  describe "fmtMsgForTTY" $ do
    it "emits coloured output when TTY" $
      let m = mkInfo "ready"
      in mustBeTrue $ isInfixOf esc (fmtMsgForTTY True m)
          && isInfixOf "[INFO]" (fmtMsgForTTY True m)

    it "emits plain text when stdout is not a TTY" $
      mustBeFalse $ isInfixOf esc (fmtMsgForTTY False (mkError "boom"))

    it "preserves message text in both modes" $
      let m = mkWarning "low"
      in mustBeTrue $ isInfixOf "low" (fmtMsgForTTY True m)
          && isInfixOf "low" (fmtMsgForTTY False m)

