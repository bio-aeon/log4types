module Log4Types.FormatSpec

import Evince
import Log4Types

export
formatSpec : Spec () ()
formatSpec = describe "Format" $ do

  describe "fmtSeverity" $ do
    it "formats Debug" (fmtSeverity Debug `mustEqual` "[DEBUG]")
    it "formats Info" (fmtSeverity Info `mustEqual` "[INFO]")
    it "formats Warning" (fmtSeverity Warning `mustEqual` "[WARNING]")
    it "formats Error" (fmtSeverity Error `mustEqual` "[ERROR]")

  describe "textRenderer" $ do
    it "renders a single field" $
      let r = textRenderer.addField "key" (StrVal "val") textRenderer.empty
      in r `mustEqual` "key=\"val\""

    it "renders multiple fields" $
      let r = textRenderer.addField "a" (IntVal 1) $
              textRenderer.addField "b" (BoolVal True) textRenderer.empty
      in r `mustEqual` "b=True a=1"

    it "combines two outputs" $
      let a = textRenderer.addField "x" (IntVal 1) ""
          b = textRenderer.addField "y" (IntVal 2) ""
      in textRenderer.combine a b `mustEqual` "x=1 y=2"

    it "empty is the identity for combine" $
      textRenderer.combine "" "x=1" `mustEqual` "x=1"

