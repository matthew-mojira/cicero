module Main where

import Lexer (runAlex)
import Parser
import Typechecker

import AST
import Interpreter
import Value

import Control.Monad
import Control.Monad.IO.Class (MonadIO, liftIO)

import System.Console.Haskeline
import System.Environment
import System.IO

main :: IO ()
main = do
  args <- getArgs
  loop

loop :: IO ()
loop = do
  read <- Main.read
  case read of
    Just str -> do
      res <- eval str
      case res of
        Left  err -> hPutStrLn stderr err
        Right val -> print val
      loop
    Nothing  -> return ()

read :: IO (Maybe String)
read = runInputT defaultSettings $ do
  minput <- getInputLine "mpl> "
  case minput of
    Nothing      -> return Nothing
    Just ""      -> return Nothing
    Just ":quit" -> return Nothing
    Just input   -> return $ Just input

eval :: String -> IO (Either String Value)
eval str = do
  case runAlex str runHappy of
    Left  err  -> return $ Left err
    Right prog -> interp prog
