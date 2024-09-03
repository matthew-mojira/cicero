module Main where

import AST
import Value
import Eval

main :: IO ()
main = do
  let prog = ExprAdd (ExprLit $ ValInt 5) (ExprLit $ ValInt 100)
  print $ prog
  print $ eval prog
