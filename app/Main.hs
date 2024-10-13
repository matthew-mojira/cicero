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

  putStrLn "   _______________                        |*\\_/*|________"
  putStrLn "  |  ___________  |     .-.     .-.      ||_/-\\_|______  |"
  putStrLn "  | |           | |    .****. .****.     | |           | |"
  putStrLn "  | |   0   0   | |    .*****.*****.     | |   0   0   | |"
  putStrLn "  | |     -     | |     .*********.      | |     -     | |"
  putStrLn "  | |   \\___/   | |      .*******.       | |   \\___/   | |"
  putStrLn "  | |___     ___| |       .*****.        | |___________| |"
  putStrLn "  |_____|\\_/|_____|        .***.         |_______________|"
  putStrLn "    _|__|/ \\|_|_.............*.............._|________|_"
  putStrLn "   / ********** \\                          / ********** \\"
  putStrLn " /  ************  \\                      /  ************  \\"
  putStrLn "--------------------                    --------------------"

  repl

loop :: Env -> IO ()
loop env = do
  read <- Main.read
  case read of
    Just str -> do
      res <- eval str env
      case res of
        Left err -> do
          printErr $ show err
          printErr str
          printErr $ errorArrow err
          loop env
        Right (val, env') -> do
          putStrLn $ concat ["=> ", show val, " : ", show (typeof val)]
          loop env'
    Nothing  -> return ()

read :: IO (Maybe String)
read = runInputT defaultSettings $ do
  minput <- getInputLine "mpl> "
  case minput of
    Nothing      -> return Nothing
    Just ""      -> return Nothing
    Just ":quit" -> return Nothing
    Just input   -> return $ Just input

eval :: String -> Env -> IO (Either Error (Value, Env))
eval str env = do
  case runAlex str runHappy of
    Left  err  -> return $ Left $ Error (AlexPn 0 0 0, AlexPn 0 0 0) (ManualError err)
    Right prog -> interp prog env

repl :: IO ()
repl = loop []

printErr :: String -> IO ()
printErr = hPutStrLn stderr
