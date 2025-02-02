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
           | TokColon
           | TokLBrack
           | TokRBrack
           | TokUnderscore

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

           -- error stuff
           | TokTry
           | TokCatch
           | TokFinally

           -- literal values
           | TokInt  Integer
           | TokId   String
           | TokStr  String
           | TokChar Char
           | TokTrue
           | TokFalse
           -- type literals
           | TokIntT
           | TokBoolT
           | TokBoxT
           | TokTypeT
           | TokFuncT
           | TokVoid

           -- I/O
           | TokPrint
           | TokScan

           deriving (Eq, Show)
