module Main

import Evince

spec : Spec () ()
spec = describe "Log4Types.JSON" $ do
  it "placeholder" $
    True `mustBe` True

main : IO ()
main = runSpec spec
