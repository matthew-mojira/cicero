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

%left  or
%left  and
%right not
%left  '+' '-'
%left  '*' '/'
%left  NEG

%token
      '+'             { TokenPosn TokPlus _ }
      '-'             { TokenPosn TokMinus _ }
      '*'             { TokenPosn TokStar _ }
      '/'             { TokenPosn TokBackslash _ }
      '('             { TokenPosn TokLParen _ }
      ')'             { TokenPosn TokRParen _ }
      int             { TokenPosn (TokInt $$) _ }
      true            { TokenPosn TokTrue _ }
      false           { TokenPosn TokFalse _ }
      and             { TokenPosn TokAnd _ }
      or              { TokenPosn TokOr _ }
      not             { TokenPosn TokNot _ }

%%

expr  : int                     { ExprLit (ValInt $1) }
      | expr '+' expr           { ExprBinOp Add $1 $3 }
      | expr '-' expr           { ExprBinOp Sub $1 $3 }
      | expr '*' expr           { ExprBinOp Mult $1 $3 }
      | expr '/' expr           { ExprBinOp Div $1 $3 }
      | expr and expr           { ExprBinOp LAnd $1 $3 }
      | expr or expr            { ExprBinOp LOr $1 $3 }
      | not expr                { ExprUnOp LNot $2 }
      | '(' expr ')'            { $2 }
      | '-' int %prec NEG       { ExprLit $ (ValInt $ -$2) }
      | true                    { ExprLit (ValBool True) }
      | false                   { ExprLit (ValBool False) }

{

lexwrap :: (TokenPosn -> Alex a) -> Alex a
lexwrap = (alexMonadScan >>=)

parseError :: TokenPosn -> Alex a
parseError (TokenPosn _ (AlexPn _ line col)) = alexError $ "parsing error at line " ++ show line ++ ", column " ++ show col

parse :: String -> Either String Prog
parse s = runAlex s runHappy

}