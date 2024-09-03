module Main where

import AST
import Value
import Eval

main :: IO ()
main = do
  let prog = ExprLit $ ValInt 5
  print $ prog
  print $ eval prog
