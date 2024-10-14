module Main where

import Lexer (runAlex, AlexPosn(AlexPn))
import Parser
import Interpreter

import Environment
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
    Run str -> do
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
    PrintEnv -> do
      print env
      loop env
    Quit -> return ()

read :: IO Command
read = runInputT defaultSettings $ do
  minput <- getInputLine "mpl> "
  case minput of
    Nothing      -> return Quit
    Just ""      -> return Quit
    Just ":quit" -> return Quit
    Just ":env"  -> return PrintEnv
    Just input   -> return $ Run input

eval :: String -> Env -> IO (Either Error (Value, Env))
eval str env = do
  case runAlex str runHappy of
    Left  err  -> return $ Left $ Error (AlexPn 0 0 0, AlexPn 0 0 0) (ManualError err)
    Right prog -> interp prog env

repl :: IO ()
repl = loop emptyEnv

printErr :: String -> IO ()
printErr = hPutStrLn stderr

data Command = Quit
             | Run String
             | PrintEnv
