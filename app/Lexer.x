{
module Lexer where

import Token
}

%wrapper "monad"

$digit = 0-9            -- digits

tokens :-

  $white+                        ;
  "--".*                         ;
  \+                             { tok TokPlus }
  (\-|−)                         { tok TokMinus }
  \*                             { tok TokStar }
  \/                             { tok TokBackslash }
  (=|==)                         { tok TokEq }
  (!=|≠)                         { tok TokNeq }
  \<                             { tok TokLe }
  (\<=|≤)                        { tok TokLeq }
  >                              { tok TokGe }
  (>=|≥)                         { tok TokGeq }
  \(                             { tok TokLParen }
  \)                             { tok TokRParen }
  $digit+                        { tok (TokInt undefined) }
  true                           { tok TokTrue }
  false                          { tok TokFalse }
  and                            { tok TokAnd }
  or                             { tok TokOr }
  (x|e)or                        { tok TokEor }
  not                            { tok TokNot }

{

alexEOF :: Alex TokenPosn
alexEOF = return Eof

tok :: Token -> AlexInput -> Int -> Alex TokenPosn
tok (TokInt _) (posn, _, _, str) len = return $ TokenPosn (TokInt (read $ take len str)) posn
tok token (posn, _, _, _) _          = return $ TokenPosn token posn

data TokenPosn = TokenPosn Token AlexPosn
               | Eof
               deriving Show

}
