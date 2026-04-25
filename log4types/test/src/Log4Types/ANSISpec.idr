module Log4Types.ANSISpec

import Data.String
import Evince
import Log4Types

esc : String
esc = "\ESC"

export
ansiSpec : Spec () ()
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

  describe "colouredTextRenderer" $ do
    it "colours severity when field name is \"severity\"" $
      let r = colouredTextRenderer.addField "severity" (StrVal "Error") colouredTextRenderer.empty
      in mustBeTrue $ isInfixOf "[ERROR]" r && isInfixOf esc r

    it "renders non-severity fields as plain key=value" $
      let r = colouredTextRenderer.addField "count" (IntVal 42) colouredTextRenderer.empty
      in r `mustEqual` "count=42"

    it "interleaves coloured severity with plain fields" $
      let r = colouredTextRenderer.addField "count" (IntVal 42) $
              colouredTextRenderer.addField "severity" (StrVal "Info") colouredTextRenderer.empty
      in mustBeTrue $ isInfixOf "[INFO]" r
          && isInfixOf "count=42" r
          && isInfixOf esc r

  describe "fmtColouredMsg" $ do
    it "includes coloured severity tag" $
      let m = mkInfo "ready"
      in mustBeTrue $ isInfixOf "[INFO]" (fmtColouredMsg m)
          && isInfixOf esc (fmtColouredMsg m)

    it "includes message text" $
      let m = mkWarning "disk low"
      in mustBeTrue $ isInfixOf "disk low" (fmtColouredMsg m)

    it "includes structured fields" $
      let m = MkMsg Info "request" [("status", IntVal 200)]
      in mustBeTrue $ isInfixOf "status=200" (fmtColouredMsg m)

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

