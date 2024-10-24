module Error where

import Lexer(AlexPosn(AlexPn), Posn)
import Pattern

data Error = Error { posn :: Posn
                   , kind :: ErrorKind
                   }

instance Show Error where
  show (Error (AlexPn _ line col, _) kind) = concat
    ["<repl>:", show line, ":", show col, ": ", show kind]

data ErrorKind = TypeError          { expected :: Pat, actual :: Pat }
               | ArithmeticError    { msg :: String }
               | NameError          { id :: String }
               | RedefinitionError  { id :: String }
               | AssignmentError    { id :: String }
               | ArityMismatchError { expArity :: Int, actArity :: Int }
               | ManualError        { msg :: String }

instance Show ErrorKind where
  show (TypeError exp act)   = unwords
    ["type error: expected value of type", show exp, "but got", show act]
  show (ArithmeticError msg) = unwords
    ["arithmetic error:", msg]
  show (NameError id) = unwords
    ["name error: identifier", id, "not in scope"]
  show (RedefinitionError id) = unwords
    ["redefinition error: identifier", id, "redeclared in the same scope"]
  show (AssignmentError id) = unwords
    ["assignment error: assignment to constant", id]
  show (ArityMismatchError exp act) = unwords
    ["type error: expected", show exp, "value(s) but got", show act]
  show (ManualError msg)     = msg

errorArrow :: Error -> String
errorArrow (Error ((AlexPn _ _ colS), (AlexPn _ _ colE)) _) =
  (replicate (colS - 1) ' ') ++ (replicate (colE - colS) '^')
