module Main

import Evince
import Log4Types.Core.ActionSpec
import Log4Types.Core.LoggableSpec
import Log4Types.Core.SeveritySpec
import Log4Types.Core.ValueSpec

main : IO ()
main = runSpec $ do
  actionSpec
  loggableSpec
  severitySpec
  valueSpec
