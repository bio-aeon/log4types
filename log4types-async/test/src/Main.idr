module Main

import Evince
import Log4Types.AsyncSpec

main : IO ()
main = runSpec $ do
  asyncSpec
