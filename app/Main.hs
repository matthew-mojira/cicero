module Main where

import Parser
import Typechecker

import Eval

import Control.Monad
import System.Console.Haskeline
import System.Environment

main :: IO ()
main = do
  args <- getArgs
  runInputT defaultSettings loop

loop :: InputT IO ()
loop = do
  minput <- getInputLine "mpl> "
  case minput of
    Nothing -> return ()
    Just ":quit" -> return ()
    Just prog -> do
      execProg prog
      loop

execProg :: String -> InputT IO ()
execProg prog =
  case parse prog of
    Left msg -> outputStrLn msg
    Right ast ->
      case typeof ast of
        Left msg -> outputStrLn msg
        Right _ -> outputStrLn $ show $ eval ast
