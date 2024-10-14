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
           | TokLBrace
           | TokRBrace
           | TokLArrow
           | TokColEq
           | TokQuestion

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
           | TokBox
           | TokUnbox

           | TokInt Integer
           | TokId  String
           deriving (Eq, Show)
