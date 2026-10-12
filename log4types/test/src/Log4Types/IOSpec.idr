module Log4Types.IOSpec

import Evince
import Log4Types

export
ioSpec : HasIO m => Spec m () ()
ioSpec = describe "IO actions" $ do

  describe "logStringStdout" $ do
    it "writes to stdout without error" $
      logStringStdout <& "test output"

  describe "logPrintLn" $ do
    it "writes Show value without error" $
      logPrintLn <& 42
