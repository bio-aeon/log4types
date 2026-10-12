module Log4Types.FileRotationSpec

import System.File
import System.File.Meta
import Evince
import Log4Types

tmpBase : String
tmpBase = "/tmp/log4types-rotation-test"

cleanup : HasIO io => io ()
cleanup = traverse_ (\suffix => ignore $ removeFile (tmpBase ++ suffix))
            ["", ".1", ".2", ".3", ".4", ".5"]

readFileOrEmpty : HasIO io => String -> io String
readFileOrEmpty path = either (const "") id <$> readFile path

tenChars : String
tenChars = "xxxxxxxxxx"

export
fileRotationSpec : HasIO m => Spec m () ()
fileRotationSpec = describe "File Rotation" $ do

  describe "withRotatingLogFile" $ do
    it "writes log lines to the base file when no rotation is needed" $ do
      cleanup
      Right () <- withRotatingLogFile tmpBase (MkRotationConfig 1_000_000 3) $ \act => do
        act <& "first line"
        act <& "second line"
        | Left _ => mustFail "open failed"
      contents <- readFileOrEmpty tmpBase
      hasFirst <- exists (tmpBase ++ ".1")
      cleanup
      (contents, hasFirst) `mustEqual` ("first line\nsecond line\n", False)

    it "rotates when the file exceeds the size limit" $ do
      cleanup
      Right () <- withRotatingLogFile tmpBase (MkRotationConfig 10 3) $ \act => do
        act <& tenChars
        act <& "ok"
        | Left _ => mustFail "open failed"
      hasOne <- exists (tmpBase ++ ".1")
      hasBase <- exists tmpBase
      rotated <- readFileOrEmpty (tmpBase ++ ".1")
      current <- readFileOrEmpty tmpBase
      cleanup
      (hasBase, hasOne, rotated, current) `mustEqual`
        (True, True, tenChars ++ "\n", "ok\n")

    it "preserves rotated files as .1, .2, .3 in order" $ do
      cleanup
      Right () <- withRotatingLogFile tmpBase (MkRotationConfig 5 5) $ \act => do
        act <& "AAAAA"
        act <& "BBBBB"
        act <& "CCCCC"
        | Left _ => mustFail "open failed"
      one   <- readFileOrEmpty (tmpBase ++ ".1")
      two   <- readFileOrEmpty (tmpBase ++ ".2")
      three <- readFileOrEmpty (tmpBase ++ ".3")
      cleanup
      (one, two, three) `mustEqual`
        ("CCCCC\n", "BBBBB\n", "AAAAA\n")

    it "deletes rotated files beyond the file limit" $ do
      cleanup
      Right () <- withRotatingLogFile tmpBase (MkRotationConfig 5 2) $ \act => do
        act <& "AAAAA"
        act <& "BBBBB"
        act <& "CCCCC"
        act <& "DDDDD"
        | Left _ => mustFail "open failed"
      hasOne   <- exists (tmpBase ++ ".1")
      hasTwo   <- exists (tmpBase ++ ".2")
      hasThree <- exists (tmpBase ++ ".3")
      cleanup
      (hasOne, hasTwo, hasThree) `mustEqual` (True, True, False)

    it "byte counter initialises from existing file size" $ do
      cleanup
      Right h <- openFile tmpBase WriteTruncate
        | Left _ => mustFail "pre-create failed"
      ignore $ fPutStrLn h "preexisting"
      closeFile h
      Right () <- withRotatingLogFile tmpBase (MkRotationConfig 5 3) $ \act => do
        act <& "more"
        | Left _ => mustFail "open failed"
      hasOne <- exists (tmpBase ++ ".1")
      cleanup
      hasOne `mustEqual` True

    it "reports an error when the log file cannot be opened" $ do
      cleanup
      result <- withRotatingLogFile "/nonexistent-dir-12345/log.txt"
                                    (MkRotationConfig 100 3)
                                    (\_ => pure ())
      mustBeLeft result

    it "keeps writing when rotation is disabled" $ do
      cleanup
      Right () <- withRotatingLogFile tmpBase (MkRotationConfig 5 0) $ \act => do
        act <& tenChars
        act <& tenChars
        act <& "tail"
        | Left _ => mustFail "open failed"
      contents <- readFileOrEmpty tmpBase
      hasOne <- exists (tmpBase ++ ".1")
      cleanup
      (hasOne, contents) `mustEqual`
        (False, tenChars ++ "\n" ++ tenChars ++ "\n" ++ "tail\n")
