module Main

import Evince
import Log4Types.ANSISpec
import Log4Types.ContextSpec
import Log4Types.FileRotationSpec
import Log4Types.FileSpec
import Log4Types.FormatSpec
import Log4Types.HasLogSpec
import Log4Types.IOSpec
import Log4Types.MessageSpec

main : IO ()
main = runSpec $ do
  ansiSpec
  contextSpec
  fileRotationSpec
  fileSpec
  formatSpec
  hasLogSpec
  ioSpec
  messageSpec
