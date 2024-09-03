module Token where

data Token = TokPlus
           | TokMinus
           | TokStar
           | TokBackslash
           | TokLParen
           | TokRParen
           | TokInt Integer
           deriving (Eq, Show)
