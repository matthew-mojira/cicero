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
  \-\>                           { tok TokRArrow }
  :=                             { tok TokColEq }
  \?                             { tok TokQuestion }
  \{                             { tok TokLBrace }
  \}                             { tok TokRBrace }
  \,                             { tok TokComma }
  \;                             { tok TokSemicolon }
  :                              { tok TokColon }
  _                              { tok TokUnderscore }
  \[                             { tok TokLBrack }
  \]                             { tok TokRBrack }

  func                           { tok TokFunc }

  true                           { tok TokTrue }
  false                          { tok TokFalse }
  and                            { tok TokAnd }
  or                             { tok TokOr }
  (x|e)or                        { tok TokEor }
  not                            { tok TokNot }

  if                             { tok TokIf }
  then                           { tok TokThen }
  else                           { tok TokElse }
  while                          { tok TokWhile }
  do                             { tok TokDo }

  var                            { tok TokVar }
  const                          { tok TokConst }
  box                            { tok TokBox }
  unbox                          { tok TokUnbox }

  try                            { tok TokTry }
  catch                          { tok TokCatch }
  finally                        { tok TokFinally }
  print                          { tok TokPrint }
  scan                           { tok TokScan }

  int_t                          { tok TokIntT }
  bool_t                         { tok TokBoolT }
  box_t                          { tok TokBoxT }
  type_t                         { tok TokTypeT }
  func_t                         { tok TokFuncT }
  void                           { tok TokVoid }

  \-?$digit+                     { tok (TokInt undefined) }
  [$alpha\_][$alpha$digit\_]*    { tok (TokId undefined) }
  \"[^\"]*\"                     { tok (TokStr undefined) }
  \'[^\']*\'                     { tok (TokChar undefined) }
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
tok (TokStr _) (posn, _, _, str) len = return $ TokenPosn (TokStr (read $ take len str)) (posn, stop)
  where
    stop = foldl alexMove posn $ take len str
tok (TokChar _) (posn, _, _, str) len = return $ TokenPosn (TokChar (read $ take len str)) (posn, stop)
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
