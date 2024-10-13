module Token where

data Token = TokPlus
           | TokMinus
           | TokStar
           | TokDoubleStar
           | TokCaret
           | TokBackslash
           | TokEq
           | TokNeq
           | TokLe
           | TokLeq
           | TokGe
           | TokGeq
           | TokTrue
           | TokFalse
           | TokAnd
           | TokOr
           | TokEor
           | TokNot

           | TokIf
           | TokThen
           | TokElse

           | TokInt Integer
           | TokLParen
           | TokRParen
           deriving (Eq, Show)
