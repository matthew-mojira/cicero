module Main where

import Lexer (runAlex)
import Parser
import Typechecker
import Interpreter

import AST

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
    Just "" -> return ()
    Just ":quit" -> return ()
    Just input -> do
      execProg input
      loop

prepareProg :: String -> Either String Prog
prepareProg str =
  runAlex str $ do
    prog <- runHappy
--  _ <- typeofExpr prog
    return prog

execProg :: String -> InputT IO ()
execProg prog =
  case prepareProg prog of
    Left msg  -> do
                   outputStrLn msg
    Right ast -> case eval ast of
                   Left _ -> undefined
                   Right o -> outputStrLn $ show o
