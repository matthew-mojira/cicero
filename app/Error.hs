module Error where

import Lexer(AlexPosn(AlexPn), Posn)
import Type

data Error = Error { posn :: Posn
                   , kind :: ErrorKind
                   }

instance Show Error where
  show (Error (AlexPn _ line col, _) kind) = concat
    ["<repl>:", show line, ":", show col, ": ", show kind]

data ErrorKind = TypeError { expected :: Type, actual :: Type }
               | ArithmeticError { msg :: String }
               | ManualError { msg :: String }

instance Show ErrorKind where
  show (TypeError exp act)   = unwords
    ["type error: expected value of type", show exp, "but got", show act]
  show (ArithmeticError msg) = unwords
    ["arithmetic error:", msg]
  show (ManualError msg)     = msg

errorArrow :: Error -> String
errorArrow (Error ((AlexPn _ _ colS), (AlexPn _ _ colE)) _) =
  (replicate (colS - 1) ' ') ++ (replicate (colE - colS) '^')
