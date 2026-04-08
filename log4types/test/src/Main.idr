module Main

import Evince
import Log4Types.ContextSpec
import Log4Types.FormatSpec
import Log4Types.HasLogSpec
import Log4Types.IOSpec
import Log4Types.MessageSpec

main : IO ()
main = runSpec $ do
  contextSpec
  formatSpec
  hasLogSpec
  ioSpec
  messageSpec
