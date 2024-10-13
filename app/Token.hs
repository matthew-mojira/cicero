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
           | TokLParen
           | TokRParen
           | TokLArrow

           | TokTrue
           | TokFalse
           | TokAnd
           | TokOr
           | TokEor
           | TokNot

           | TokIf
           | TokThen
           | TokElse

           | TokVar
           | TokConst

           | TokInt Integer
           | TokId  String
           deriving (Eq, Show)
