module Main where

import Lexer (runAlex, AlexPosn(AlexPn))
import Parser
import Interpreter

import Error
import Value

import System.Console.Haskeline
import System.Environment
import System.IO

main :: IO ()
main = do
  args <- getArgs
  repl

loop :: IO ()
loop = do
  read <- Main.read
  case read of
    Just str -> do
      res <- eval str
      case res of
        Left  err -> do
          printErr $ show err
          printErr str
          printErr $ errorArrow err
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

eval :: String -> IO (Either Error Value)
eval str = do
  case runAlex str runHappy of
    Left  err  -> return $ Left $ Error (AlexPn 0 0 0, AlexPn 0 0 0) (ManualError err)
    Right prog -> interp prog

repl :: IO ()
repl = loop

printErr :: String -> IO ()
printErr = hPutStrLn stderr
