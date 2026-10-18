module Log4Types.FormatSpec

import Evince
import Log4Types

userFields : List (String, LogParamValue)
userFields = [("name", StrVal "alice"), ("age", IntVal 30)]

export
formatSpec : Applicative m => Spec m () ()
formatSpec = describe "Format" $ do

  describe "fmtSeverity" $ do
    it "formats Debug" (fmtSeverity Debug `mustEqual` "[DEBUG]")
    it "formats Info" (fmtSeverity Info `mustEqual` "[INFO]")
    it "formats Warning" (fmtSeverity Warning `mustEqual` "[WARNING]")
    it "formats Error" (fmtSeverity Error `mustEqual` "[ERROR]")

  describe "fieldsRenderer" $ do
    it "appends fields in the order they are added" $
      fieldsRenderer.addField "age" (IntVal 30) (fieldsRenderer.addField "name" (StrVal "alice") [])
        `mustEqual` [("name", StrVal "alice"), ("age", IntVal 30)]

    it "prefixes every field of a nested object with its name" $
      fieldsRenderer.addNested "user" (++ userFields) [("id", IntVal 7)]
        `mustEqual` [("id", IntVal 7), ("user.name", StrVal "alice"), ("user.age", IntVal 30)]

    it "prefixes fields nested two levels deep with both names" $
      fieldsRenderer.addNested "order" (fieldsRenderer.addNested "user" (++ userFields)) []
        `mustEqual` [("order.user.name", StrVal "alice"), ("order.user.age", IntVal 30)]

    it "adds nothing for an empty nested object" $
      fieldsRenderer.addNested "secret" id [("id", IntVal 7)] `mustEqual` [("id", IntVal 7)]

  describe "fmtFields" $ do
    it "renders fields as space-separated key=value pairs" $
      fmtFields userFields `mustEqual` "name=\"alice\" age=30"

