module Log4Types.IOSpec

import Data.IORef
import Evince
import Log4Types

export
ioSpec : Spec () ()
ioSpec = describe "IO actions" $ do

  describe "logStringStdout" $ do
    itIO "writes to stdout without error" $ do
      logStringStdout <& "test output"
      pure (mustBeTrue True)

  describe "logPrintLn" $ do
    itIO "writes Show value without error" $ do
      logPrintLn <& the Int 42
      pure (mustBeTrue True)
