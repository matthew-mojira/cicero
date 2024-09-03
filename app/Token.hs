module Token where

data Token = TokPlus
           | TokMinus
           | TokStar
           | TokBackslash
           | TokLParen
           | TokRParen
           | TokTrue
           | TokFalse
           | TokAnd
           | TokOr
           | TokEor
           | TokNot
           | TokInt Integer
           deriving (Eq, Show)
