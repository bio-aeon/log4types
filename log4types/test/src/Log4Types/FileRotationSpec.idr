module Log4Types.FileRotationSpec

import System.File
import System.File.Meta
import Evince
import Log4Types

tmpBase : String
tmpBase = "/tmp/log4types-rotation-test"

cleanup : IO ()
cleanup = traverse_ (\suffix => ignore $ removeFile (tmpBase ++ suffix))
            ["", ".1", ".2", ".3", ".4", ".5"]

readFileOrEmpty : String -> IO String
readFileOrEmpty path = do
  Right contents <- readFile path
    | Left _ => pure ""
  pure contents

tenChars : String
tenChars = "xxxxxxxxxx"

export
fileRotationSpec : Spec () ()
fileRotationSpec = describe "File Rotation" $ do

  describe "RotationConfig" $ do
    it "defaultRotation has 10 MB threshold" $
      defaultRotation.maxBytes `mustEqual` 10_000_000

    it "defaultRotation keeps 5 files" $
      defaultRotation.maxFiles `mustEqual` 5

  describe "withRotatingLogFile" $ do
    itIO "writes log lines to the base file when no rotation is needed" $ do
      cleanup
      Right () <- withRotatingLogFile tmpBase (MkRotationConfig 1_000_000 3) $ \act => do
        act <& "first line"
        act <& "second line"
        | Left _ => pure (mustFail "open failed")
      contents <- readFileOrEmpty tmpBase
      hasFirst <- exists (tmpBase ++ ".1")
      cleanup
      pure $ (contents, hasFirst) `mustEqual` ("first line\nsecond line\n", False)

    itIO "rotates when maxBytes exceeded" $ do
      cleanup
      Right () <- withRotatingLogFile tmpBase (MkRotationConfig 10 3) $ \act => do
        act <& tenChars
        act <& "ok"
        | Left _ => pure (mustFail "open failed")
      hasOne <- exists (tmpBase ++ ".1")
      hasBase <- exists tmpBase
      rotated <- readFileOrEmpty (tmpBase ++ ".1")
      current <- readFileOrEmpty tmpBase
      cleanup
      pure $ (hasBase, hasOne, rotated, current) `mustEqual`
             (True, True, tenChars ++ "\n", "ok\n")

    itIO "preserves rotated files as .1, .2, .3 in order" $ do
      cleanup
      Right () <- withRotatingLogFile tmpBase (MkRotationConfig 5 5) $ \act => do
        act <& "AAAAA"
        act <& "BBBBB"
        act <& "CCCCC"
        | Left _ => pure (mustFail "open failed")
      one   <- readFileOrEmpty (tmpBase ++ ".1")
      two   <- readFileOrEmpty (tmpBase ++ ".2")
      three <- readFileOrEmpty (tmpBase ++ ".3")
      cleanup
      pure $ (one, two, three) `mustEqual`
             ("CCCCC\n", "BBBBB\n", "AAAAA\n")

    itIO "deletes files beyond maxFiles" $ do
      cleanup
      Right () <- withRotatingLogFile tmpBase (MkRotationConfig 5 2) $ \act => do
        act <& "AAAAA"
        act <& "BBBBB"
        act <& "CCCCC"
        act <& "DDDDD"
        | Left _ => pure (mustFail "open failed")
      hasOne   <- exists (tmpBase ++ ".1")
      hasTwo   <- exists (tmpBase ++ ".2")
      hasThree <- exists (tmpBase ++ ".3")
      cleanup
      pure $ (hasOne, hasTwo, hasThree) `mustEqual` (True, True, False)

    itIO "byte counter initialises from existing file size" $ do
      cleanup
      Right h <- openFile tmpBase WriteTruncate
        | Left _ => pure (mustFail "pre-create failed")
      ignore $ fPutStrLn h "preexisting"
      closeFile h
      Right () <- withRotatingLogFile tmpBase (MkRotationConfig 5 3) $ \act => do
        act <& "more"
        | Left _ => pure (mustFail "open failed")
      hasOne <- exists (tmpBase ++ ".1")
      cleanup
      pure $ hasOne `mustEqual` True

    itIO "open failure returns Left FileError" $ do
      cleanup
      Left _ <- withRotatingLogFile "/nonexistent-dir-12345/log.txt"
                                    (MkRotationConfig 100 3)
                                    (\_ => pure ())
        | Right _ => pure (mustFail "expected open failure")
      pure (mustBeTrue True)

    itIO "keeps writing when rotation is disabled (maxFiles=0)" $ do
      cleanup
      Right () <- withRotatingLogFile tmpBase (MkRotationConfig 5 0) $ \act => do
        act <& tenChars
        act <& tenChars
        act <& "tail"
        | Left _ => pure (mustFail "open failed")
      contents <- readFileOrEmpty tmpBase
      hasOne <- exists (tmpBase ++ ".1")
      cleanup
      pure $ (hasOne, contents) `mustEqual`
             (False, tenChars ++ "\n" ++ tenChars ++ "\n" ++ "tail\n")
