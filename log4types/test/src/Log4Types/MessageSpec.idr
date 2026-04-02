module Log4Types.MessageSpec

import Evince
import Log4Types

export
messageSpec : Spec () ()
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

  describe "Msg with fields" $ do
    it "show includes fields" $
      let msg = MkMsg Info "request" [("status", IntVal 200)]
      in show msg `mustEqual` "[INFO] request status=200"

  describe "SimpleMsg" $ do
    it "show formats severity and text" $
      show (MkSimpleMsg Warning "disk low") `mustEqual` "[WARNING] disk low"
