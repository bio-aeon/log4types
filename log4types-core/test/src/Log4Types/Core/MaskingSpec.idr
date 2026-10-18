module Log4Types.Core.MaskingSpec

import Evince
import Log4Types.Core

testRenderer : LogRenderer (List (String, LogParamValue))
testRenderer = MkLogRenderer
  { addField  = \name, val, acc => acc ++ [(name, val)]
  , addNested = \name, build, acc => acc ++ build []
  , empty     = []
  , combine   = (++)
  }

record User where
  constructor MkUser
  name     : String
  email    : Masked String
  password : Hidden String

Loggable User where
  logFields renderer u acc =
    addLoggableField renderer "password" u.password $
    addLoggableField renderer "email" u.email $
    addLoggableField renderer "name" u.name acc
  logShow u = u.name

export
maskingSpec : Applicative m => Spec m () ()
maskingSpec = describe "Masking" $ do

  describe "Masked" $ do
    it "renders its fields as ***" $
      logFields testRenderer (MkMasked "secret") [] `mustEqual` [("value", StrVal "***")]

    it "shows as ***" $
      logShow (MkMasked "secret") `mustEqual` "***"

  describe "Hidden" $ do
    it "renders no fields" $
      logFields testRenderer (MkHidden "secret") [] `mustEqual` []

    it "shows as the empty string" $
      logShow (MkHidden "secret") `mustEqual` ""

  describe "lastN" $ do
    it "keeps the last characters and masks the rest" $
      (lastN 4).mask "4111111111111111" `mustEqual` "************1111"

    it "masks a value no longer than the kept length entirely" $
      (lastN 4).mask "1234" `mustEqual` "***"

  describe "emailDomainOnly" $ do
    it "masks the local part and keeps the domain" $
      emailDomainOnly.mask "alice@example.com" `mustEqual` "*****@example.com"

    it "splits at the last @" $
      emailDomainOnly.mask "ab@cd@example.com" `mustEqual` "*****@example.com"

    it "masks a value without @ entirely" $
      emailDomainOnly.mask "alice" `mustEqual` "***"

  describe "addMaskedField" $ do
    it "writes the policy's rendering under the given name" $
      addMaskedField testRenderer "card" (lastN 4) "4111111111111111" []
        `mustEqual` [("card", StrVal "************1111")]

  describe "records" $ do
    it "masks Masked fields, omits Hidden ones and keeps plain ones" $
      let user = MkUser "alice" (MkMasked "alice@example.com") (MkHidden "hunter2")
      in logFields testRenderer user [] `mustEqual` [("name", StrVal "alice"), ("email", StrVal "***")]
