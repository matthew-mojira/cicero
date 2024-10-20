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
           | TokRArrow
           | TokComma
           | TokColEq
           | TokQuestion
           | TokSemicolon

           | TokFunc

           | TokTrue
           | TokFalse
           | TokAnd
           | TokOr
           | TokEor
           | TokNot

           | TokIf
           | TokThen
           | TokElse
           | TokWhile
           | TokDo

           | TokVar
           | TokConst
           | TokBox
           | TokUnbox

           | TokInt Integer
           | TokId  String
           deriving (Eq, Show)
