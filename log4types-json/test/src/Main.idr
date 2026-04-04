module Main

import Evince
import Log4Types.JSONSpec

main : IO ()
main = runSpec $ do
  jsonSpec
