{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

import Text.DocLayout
import Test.Tasty
import Test.Tasty.HUnit
import Data.Text (Text)

main :: IO ()
main = defaultMain $ testGroup "Tests" tests

tests :: [TestTree]
tests =
  [ testCase "simple vcat " $
      render (Just 10) (vcat $ map chomp ["aaa", "bbb", "ccc"])
      @?= ("aaa\nbbb\nccc\n" :: String)

  , testCase "variant" $
      render (Just 10) ((chomp "aaa") $$ (chomp "bbb") $$ (chomp "ccc"))
      @?= ("aaa\nbbb\nccc\n" :: String)

  , testCase "simple text above line length" $
      render (Just 4) ("hello" <+> "there")
      @?= ("hello\nthere\n" :: String)

  , testCase "cr" $
      render (Just 60) ("hello" <> cr <> "there")
      @?= ("hello\nthere\n" :: String)

  , testCase "wrapping" $
      render (Just 10) (hsep ["hello", "there", "this", "is", "a", "test"])
      @?= ("hello\nthere this\nis a test\n" :: String)

  , testCase "simple box wrapping" $
      render (Just 50) (box 3 "aa" <> box 3 "bb" <> box 3 ("aa" <+> "bbbb"))
      @?= ("aa bb aa\n      bbbb\n" :: Text)

  , testCase "nontrivial empty doc" $
      isEmpty (nest 5 (alignCenter empty))
      @?= True

  , testCase "nontrivial nonempty doc" $
      isEmpty (box 1 (text "a"))
      @?= False

  , testCase "prefixed with multi paragraphs" $
      render (Just 80) (prefixed "> " ("foo" <> cr <> "bar" <> blankline <> "baz"))
      @?= ("> foo\n> bar\n>\n> baz\n" :: String)

  , testCase "breaking space before empty box" $
      render Nothing ("a" <> space <> box 3 mempty)
      @?= ("a\n" :: String)

  , testCase "centered" $
      render (Just 10) (alignCenter "hi\nlow")
      @?= ("    hi\n   low\n" :: String)

  , testCase "vfill" $
      render Nothing (vfill "|" <> box 2 (vcat $ replicate 4 "aa") <>
                      vfill "|")
      @?= ("|aa|\n|aa|\n|aa|\n|aa|\n" :: Text)

  , testCase "nest" $
      render Nothing (nest 4 "aa\n\nbb\ncc")
      @?= ("    aa\n\n    bb\n    cc\n" :: Text)

  , testCase "aligned" $
      render Nothing ("aa" <> aligned ("bb" $$ "cc") <> "dd")
      @?= ("aabb\n  ccdd\n" :: Text)

  , testCase "align with box" $
      render Nothing ("aa" <> box 2 ("bb" $$ "cc") <> "dd")
      @?= ("aabbdd\n  cc\n" :: Text)

  , testCase "centered box" $
      render Nothing ("aa" <> box 4 (alignCenter $ "bb" $$ "cc") <> "dd")
      @?= ("aa bb dd\n   cc\n" :: Text)

  , testCase "blanks at beginning" $
      render Nothing (blanklines 2 <> "aa")
      @?= ("aa\n" :: Text)

  , testCase "blanks at end" $
      render Nothing ("aa" <> blanklines 2)
      @?= ("aa\n" :: Text)

  , testCase "chomp 1" $
      render Nothing (chomp (("aa" <> space) <> blankline) <> "bb")
      @?= ("aabb\n" :: Text)

  , testCase "chomp 2" $
      render Nothing (chomp ("aa" <> space) <> "bb")
      @?= ("aabb\n" :: Text)

  , testCase "chomp 3" $
      render Nothing (chomp "aa")
      @?= ("aa\n" :: Text)

  , testCase "chomp with nesting" $
      render Nothing (chomp (nest 3 ("aa" <> blankline)) <> "bb" <> cr <> "cc")
      @?= ("   aabb\ncc\n" :: Text)

  , testCase "chomp with alignment" $
      render (Just 4) (chomp (alignCenter ("aa\nbb" <> blankline)))
      @?= (" aa\nbb\n" :: Text)
      -- last line is left aligned because we pop alignment before
      -- the line is emitted

  , testCase "chomp with box at end" $
      render Nothing ("aa" <> cr <> chomp (box 2 ("aa" <> blankline) <> blankline))
      @?= ("aa\naa\n" :: Text)

  , testCase "empty and $$" $
      render Nothing ("aa" $$ empty $$ "bb")
      @?= ("aa\nbb\n" :: Text)

  , testCase "table" $
      render Nothing ((rblock 4 "aa" <> lblock 3 " | " <> cblock 4 "bb" <>
                          lblock 3 " | " <> lblock 4 "cc") $$
                      (rblock 4 "----" <> lblock 3 " | " <> cblock 4 "----" <>
                          lblock 3 " | " <> lblock 4 "----") $$
                      (rblock 4 "dd" <> lblock 3 " | " <> cblock 4 "ee" <>
                          lblock 3 " | " <> lblock 4 "ff"))
      @?= ("  aa |  bb  | cc\n---- | ---- | ----\n  dd |  ee  | ff\n" :: Text)

  ]
