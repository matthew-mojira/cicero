module Main where

import Parser
import Typechecker

import Eval

import System.IO
import Control.Monad

main :: IO ()
main = forever $ do
  putStr "mpl> "
  hFlush stdout
  prog <- getLine

  case parse prog of
    Left msg  -> putStrLn msg
    Right ast -> case typeof ast of
                   Left msg -> putStrLn msg
                   Right _  -> print $ eval ast
