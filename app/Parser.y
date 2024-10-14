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
%left  '=' '!='
%left  '<' '<=' '>' '>='
%left  '+' '-'
%left  '*' '/'
%right '**'
%left  NEG
%right not

%token
      '+'             { TokenPosn TokPlus (_, _) }
      '-'             { TokenPosn TokMinus (_, _) }
      '*'             { TokenPosn TokStar (_, _) }
      '**'            { TokenPosn TokDoubleStar (_, _) }
      '^'             { TokenPosn TokCaret (_, _) }
      '/'             { TokenPosn TokBackslash (_, _) }
      '='             { TokenPosn TokEq (_, _) }
      '!='            { TokenPosn TokNeq (_, _) }
      '<'             { TokenPosn TokLe (_, _) }
      '<='            { TokenPosn TokLeq (_, _) }
      '>'             { TokenPosn TokGe (_, _) }
      '>='            { TokenPosn TokGeq (_, _) }
      '('             { TokenPosn TokLParen (_, _) }
      ')'             { TokenPosn TokRParen (_, _) }
      '<-'            { TokenPosn TokLArrow (_, _) }
      ':='            { TokenPosn TokColEq (_, _) }
      '?'             { TokenPosn TokQuestion (_, _) }
      '{'             { TokenPosn TokLBrace (_, _) }
      '}'             { TokenPosn TokRBrace (_, _) }

      int             { TokenPosn (TokInt _) (_, _) }
      id              { TokenPosn (TokId _) (_, _) }

      true            { TokenPosn TokTrue (_, _) }
      false           { TokenPosn TokFalse (_, _) }
      and             { TokenPosn TokAnd (_, _) }
      or              { TokenPosn TokOr (_, _) }
      not             { TokenPosn TokNot (_, _) }
      if              { TokenPosn TokIf (_, _) }
      then            { TokenPosn TokThen (_, _) }
      else            { TokenPosn TokElse (_, _) }

      var             { TokenPosn TokVar (_, _) }
      const           { TokenPosn TokConst (_, _) }
      box             { TokenPosn TokBox (_, _) }
      unbox           { TokenPosn TokUnbox (_, _) }
%%

expr  : int                     { parseInt $1 }
      | expr '+' expr           { (ExprBinOp Add $1 $3, ($1 <|> $3)) }
      | expr '-' expr           { (ExprBinOp Sub $1 $3, ($1 <|> $3)) }
      | expr '*' expr           { (ExprBinOp Mult $1 $3, ($1 <|> $3)) }
      | expr '**' expr          { (ExprBinOp Exp $1 $3, ($1 <|> $3)) }
      | expr '^' expr           { (ExprBinOp Exp $1 $3, ($1 <|> $3)) }
      | expr '/' expr           { (ExprBinOp Div $1 $3, ($1 <|> $3)) }
      | expr and expr           { (ExprBinOp LAnd $1 $3, ($1 <|> $3)) }
      | expr or expr            { (ExprBinOp LOr $1 $3, ($1 <|> $3)) }
      | expr '=' expr           { (ExprBinOp Eq $1 $3, ($1 <|> $3)) }
      | expr '!=' expr          { (ExprBinOp Neq $1 $3, ($1 <|> $3)) }
      | expr '<' expr           { (ExprBinOp Le $1 $3, ($1 <|> $3)) }
      | expr '<=' expr          { (ExprBinOp Leq $1 $3, ($1 <|> $3)) }
      | expr '>' expr           { (ExprBinOp Ge $1 $3, ($1 <|> $3)) }
      | expr '>=' expr          { (ExprBinOp Geq $1 $3, ($1 <|> $3)) }
      | not expr                { parseUnOp LNot $1 $2 }

      | '(' expr ')'            { (fst $2, tokenPosn $1 <-> tokenPosn $3) }
      | '{' exprs '}'           { (ExprBlock $2, tokenPosn $1 <-> tokenPosn $3)}
      
      | '-' int %prec NEG       { parseNInt $1 $2 }

      | var id '=' expr         { parseVar $1 $2 $4 }
      | const id '=' expr       { parseConst $1 $2 $4 }
      | id                      { parseId $1 }
      | id ':=' expr            { parseAssign $1 $3 }

      | expr '?'                { (ExprUnOp Typeof $1, snd $1 <-> tokenPosn $2)}
      
      | box expr                { parseUnOp Box $1 $2 }
      | unbox expr              { parseUnOp Unbox $1 $2 }
      | expr '<-' expr          { (ExprSetBox $1 $3, ($1 <|> $3)) }

      | if expr then expr else expr { (ExprIfElse $2 $4 $6, tokenPosn $1 <-> snd $6) }
      | true                    { (ExprLit (ValBool True), tokenPosn $1) }
      | false                   { (ExprLit (ValBool False), tokenPosn $1) }

exprs :                         { [] }
      | expr exprs              { $1 : $2 }

{

parseInt :: TokenPosn -> ExprPosn
parseInt (TokenPosn (TokInt int) pos) =
  (ExprLit (ValInt int), pos)

parseNInt :: TokenPosn -> TokenPosn -> ExprPosn
parseNInt (TokenPosn _ pos1) (TokenPosn (TokInt int) pos2) =
  (ExprLit (ValInt $ -int), pos1 <-> pos2)

parseUnOp :: UnOp -> TokenPosn -> ExprPosn -> ExprPosn
parseUnOp op (TokenPosn _ pos1) expr@(_, pos2) =
  (ExprUnOp op expr, pos1 <-> pos2)

parseVar :: TokenPosn -> TokenPosn -> ExprPosn -> ExprPosn
parseVar (TokenPosn _ pos1) (TokenPosn (TokId id) _) expr@(_, pos2) =
  (ExprVar id expr, pos1 <-> pos2)

parseConst :: TokenPosn -> TokenPosn -> ExprPosn -> ExprPosn
parseConst (TokenPosn _ pos1) (TokenPosn (TokId id) _) expr@(_, pos2) =
  (ExprConst id expr, pos1 <-> pos2)

parseId :: TokenPosn -> ExprPosn
parseId (TokenPosn (TokId id) pos) = (ExprId id, pos)

parseAssign :: TokenPosn -> ExprPosn -> ExprPosn
parseAssign (TokenPosn (TokId id) pos1) expr@(_, pos2) =
  (ExprAssign id expr, pos1 <-> pos2)

tokenPosn :: TokenPosn -> (AlexPosn, AlexPosn)
tokenPosn (TokenPosn _ pos) = pos

(<|>) :: ExprPosn -> ExprPosn -> (AlexPosn, AlexPosn)
(_, (pos1, _)) <|> (_, (_, pos2)) = (pos1, pos2)

(<->) :: (AlexPosn, AlexPosn) -> (AlexPosn, AlexPosn) -> (AlexPosn, AlexPosn)
(pos1, _) <-> (_, pos2) = (pos1, pos2)

lexwrap :: (TokenPosn -> Alex a) -> Alex a
lexwrap = (alexMonadScan >>=)

parseError :: TokenPosn -> Alex a
parseError (TokenPosn _ (AlexPn _ line col, _)) = alexError $ "parsing error at line " ++ show line ++ ", column " ++ show col
parseError Eof = alexError $ "received empty input"

parse :: String -> Either String Prog
parse str = runAlex str runHappy

}
