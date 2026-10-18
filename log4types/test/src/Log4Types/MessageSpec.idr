module Log4Types.MessageSpec

import Evince
import Log4Types

export
messageSpec : Applicative m => Spec m () ()
messageSpec = describe "Message" $ do

  describe "mkDebug" $ do
    it "sets severity to Debug" (severity (mkDebug "hi") `mustEqual` Debug)
    it "sets the text" (text (mkDebug "hi") `mustEqual` "hi")
    it "has no fields" (fields (mkDebug "hi") `mustEqual` [])

  describe "mkInfo" $ do
    it "sets severity to Info" (severity (mkInfo "hi") `mustEqual` Info)

  describe "mkWarning" $ do
    it "sets severity to Warning" (severity (mkWarning "hi") `mustEqual` Warning)

  describe "mkError" $ do
    it "sets severity to Error" (severity (mkError "hi") `mustEqual` Error)

  describe "fmtMsgWith" $ do
    it "renders the tag, the text and the fields on one line" $
      fmtMsgWith show (MkMsg Warning "disk low" [("percent", IntVal 92)])
        `mustEqual` "Warning disk low percent=92"

    it "ends the line with the text when there are no fields" $
      fmtMsgWith show (mkInfo "ready") `mustEqual` "Info ready"

  describe "Msg" $ do
    it "shows its severity as a bracketed tag" $
      show (mkInfo "ready") `mustEqual` "[INFO] ready"

  describe "SimpleMsg" $ do
    it "show formats severity and text" $
      show (MkSimpleMsg Warning "disk low") `mustEqual` "[WARNING] disk low"
