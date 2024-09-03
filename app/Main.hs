module Main where

import Parser

import Eval

import System.IO
import Control.Monad

main :: IO ()
main = forever $ do
  putStr "mpl> "
  hFlush stdout
  prog <- getLine

  let result = parse prog
  case result of
    Left msg  -> putStrLn msg
    Right ast -> do
                    -- print $ ast
                    print $ eval ast
