module Log4Types.FileSpec

import System.File
import Evince
import Log4Types

tmpFile : String
tmpFile = "/tmp/log4types-test.log"

cleanup : IO ()
cleanup = ignore $ removeFile tmpFile

export
fileSpec : Spec () ()
fileSpec = describe "File" $ do

  describe "logStringHandle" $ do
    itIO "writes to file handle" $ do
      cleanup
      Right h <- openFile tmpFile WriteTruncate
        | Left _ => pure (mustFail "failed to open file")
      let act = logStringHandle h
      act <& "line one"
      act <& "line two"
      closeFile h
      Right contents <- readFile tmpFile
        | Left _ => pure (mustFail "failed to read file")
      cleanup
      pure $ contents `mustEqual` "line one\nline two\n"

  describe "withLogFile" $ do
    itIO "creates file and appends" $ do
      cleanup
      Right () <- withLogFile tmpFile $ \act => do
        act <& "appended line"
        | Left _ => pure (mustFail "failed to open file")
      Right contents <- readFile tmpFile
        | Left _ => pure (mustFail "failed to read file")
      cleanup
      pure $ contents `mustEqual` "appended line\n"
