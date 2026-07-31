module Main

import Evince
import Log4Types.AsyncJsSpec

main : IO ()
main = runSpec $ do
  asyncJsSpec
