{
module Lexer where

import Token
}

%wrapper "basic"

$digit = 0-9            -- digits

tokens :-

  $white+                        ;
  "--".*                         ;
  \+                             { \s -> TokPlus }
  $digit+                        { \s -> TokInt (read s) }
