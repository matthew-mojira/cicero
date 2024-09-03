{

module Parser where

import Token
import AST
import Value

}

%name parse
%tokentype { Token }
%error { undefined }

%left '+' '-'

%token
      '+'             { TokPlus }
      int             { TokInt $$ }

%%

expr  : int                     { ExprLit (ValInt $1) }
      | expr '+' expr           { ExprAdd $1 $3 }
