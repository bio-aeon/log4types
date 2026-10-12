module Log4Types.FileSpec

import System.File
import Evince
import Log4Types

tmpFile : String
tmpFile = "/tmp/log4types-test.log"

cleanup : HasIO io => io ()
cleanup = ignore $ removeFile tmpFile

export
fileSpec : HasIO m => Spec m () ()
fileSpec = describe "File" $ do

  describe "logStringHandle" $ do
    it "writes to file handle" $ do
      cleanup
      Right h <- openFile tmpFile WriteTruncate
        | Left _ => mustFail "failed to open file"
      let act = logStringHandle h
      act <& "line one"
      act <& "line two"
      closeFile h
      Right contents <- readFile tmpFile
        | Left _ => mustFail "failed to read file"
      cleanup
      contents `mustEqual` "line one\nline two\n"

  describe "withLogFile" $ do
    it "creates file and appends" $ do
      cleanup
      Right () <- withLogFile tmpFile $ \act => do
        act <& "appended line"
        | Left _ => mustFail "failed to open file"
      Right contents <- readFile tmpFile
        | Left _ => mustFail "failed to read file"
      cleanup
      contents `mustEqual` "appended line\n"
