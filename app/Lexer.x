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
  $digit+                        { tok (TokInt undefined) }

{

alexEOF :: Alex TokenPosn
alexEOF = return Eof

tok :: Token -> AlexInput -> Int -> Alex TokenPosn
tok TokPlus (posn, _, _, _) _        = return $ TokenPosn TokPlus posn
tok (TokInt _) (posn, _, _, str) len = return $ TokenPosn (TokInt (read $ take len str)) posn

data TokenPosn = TokenPosn Token AlexPosn
               | Eof
               deriving Show

}
