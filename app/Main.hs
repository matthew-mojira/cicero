module Main where

import Lexer
import Parser

import AST
import Value
import Eval

import System.IO
import Control.Monad

-- repl
main :: IO ()
main = forever $ do
  putStr "mpl> "
  hFlush stdout
  prog <- getLine

  let ast = parse $ alexScanTokens prog
  print $ eval ast

{-
  let prog = "5 + 10"
  let toks = alexScanTokens prog
  let ast  = parse toks

  putStrLn $ "Input: " ++ prog
  putStrLn $ "Parsed: " ++ show ast

  print $ eval ast
-}
