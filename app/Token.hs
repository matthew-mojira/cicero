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

           -- boolean operations
           | TokAnd
           | TokOr
           | TokEor
           | TokNot

           -- conditional operations
           | TokIf
           | TokThen
           | TokElse
           | TokWhile
           | TokDo

           | TokVar
           | TokConst
           | TokBox
           | TokUnbox

           -- literal values
           | TokInt Integer
           | TokId  String
           | TokTrue
           | TokFalse
           -- type literals
           | TokIntT
           | TokBoolT
           | TokBoxT
           | TokTypeT
           | TokFuncT

           deriving (Eq, Show)
