{

module Parser where

import Lexer
import Token
import AST
import Value

}

%name      runHappy
%error     { parseError }
%lexer     { lexwrap } { Eof }
%monad     { Alex }
%tokentype { TokenPosn }

%left '+' '-'

%token
      '+'             { TokenPosn TokPlus _ }
      int             { TokenPosn (TokInt $$) _ }

%%

expr  : int                     { ExprLit (ValInt $1) }
      | expr '+' expr           { ExprAdd $1 $3 }

{

lexwrap :: (TokenPosn -> Alex a) -> Alex a
lexwrap = (alexMonadScan >>=)

parseError :: TokenPosn -> Alex a
parseError (TokenPosn _ (AlexPn _ line col)) = alexError $ "parsing error at line " ++ show line ++ ", column " ++ show col

parse :: String -> Either String Prog
parse s = runAlex s runHappy

}
