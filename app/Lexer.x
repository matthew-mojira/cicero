{
module Lexer where

import Token
}

%wrapper "monad"

$digit = 0-9            -- digits
$alpha = [a-zA-Z]       -- alphabetic characters

tokens :-

  $white+                        ;
  "--".*                         ;
  \+                             { tok TokPlus }
  (\-|−)                         { tok TokMinus }
  \*                             { tok TokStar }
  \*\*                           { tok TokDoubleStar }
  \^                             { tok TokCaret }
  \/                             { tok TokBackslash }
  (=|==)                         { tok TokEq }
  (!=|≠)                         { tok TokNeq }
  \<                             { tok TokLe }
  (\<=|≤)                        { tok TokLeq }
  >                              { tok TokGe }
  (>=|≥)                         { tok TokGeq }
  \(                             { tok TokLParen }
  \)                             { tok TokRParen }
  \<\-                           { tok TokLArrow }
  \?                             { tok TokQuestion }

  true                           { tok TokTrue }
  false                          { tok TokFalse }
  and                            { tok TokAnd }
  or                             { tok TokOr }
  (x|e)or                        { tok TokEor }
  not                            { tok TokNot }

  if                             { tok TokIf }
  then                           { tok TokThen }
  else                           { tok TokElse }

  var                            { tok TokVar }
  const                          { tok TokConst }

  $digit+                        { tok (TokInt undefined) }
  $alpha [$alpha $digit \_]*     { tok (TokId undefined) }

{

alexEOF :: Alex TokenPosn
alexEOF = return Eof

tok :: Token -> AlexInput -> Int -> Alex TokenPosn
tok (TokId _) (posn, _, _, str) len = return $ TokenPosn (TokId (take len str)) (posn, stop)
  where
    stop = foldl alexMove posn $ take len str
tok (TokInt _) (posn, _, _, str) len = return $ TokenPosn (TokInt (read $ take len str)) (posn, stop)
  where
    stop = foldl alexMove posn $ take len str
tok token (posn, _, _, str) len = return $ TokenPosn token (posn, stop)
  where
    stop = foldl alexMove posn $ take len str

data TokenPosn = TokenPosn Token (AlexPosn, AlexPosn) -- (start, end)
               | Eof
               deriving Show

type Posn = (AlexPosn, AlexPosn)
}
