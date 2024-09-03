module Token where

data Token = TokPlus
           | TokMinus
           | TokStar
           | TokBackslash
           | TokLParen
           | TokRParen
           | TokTrue
           | TokFalse
           | TokInt Integer
           deriving (Eq, Show)
