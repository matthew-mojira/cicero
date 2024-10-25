{

module Parser where

import Lexer
import Token
import AST

}

%name      runHappy
%error     { parseError }
%lexer     { lexwrap } { Eof }
%monad     { Alex }
%tokentype { TokenPosn }

%left  '->'
%right else
%right ':=' '<-'
%left  or
%left  and
%left  '=' '!='
%left  '<' '<=' '>' '>='
%left  '+' '-'
%left  '*' '/'
%right '**' '^'
%left  NEG
%right not box unbox
%left  '?'
%left  APPLY

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
      '{'             { TokenPosn TokLBrace (_, _) }
      '}'             { TokenPosn TokRBrace (_, _) }
      '['             { TokenPosn TokLBrack (_, _) }
      ']'             { TokenPosn TokRBrack (_, _) }
      '<-'            { TokenPosn TokLArrow (_, _) }
      '->'            { TokenPosn TokRArrow (_, _) }
      ':='            { TokenPosn TokColEq (_, _) }
      '?'             { TokenPosn TokQuestion (_, _) }
      ','             { TokenPosn TokComma (_, _) }
      ';'             { TokenPosn TokSemicolon (_, _) }
      ':'             { TokenPosn TokColon (_, _) }
      '_'             { TokenPosn TokUnderscore (_, _) }

      int             { TokenPosn (TokInt _) (_, _) }
      id              { TokenPosn (TokId _) (_, _) }

      func            { TokenPosn TokFunc (_, _) }

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

      int_t           { TokenPosn TokIntT (_, _) }
      bool_t          { TokenPosn TokBoolT (_, _) }
      box_t           { TokenPosn TokBoxT (_, _) }
      type_t          { TokenPosn TokTypeT (_, _) }
      func_t          { TokenPosn TokFuncT (_, _) }
%%

exprs :                         { [] }
      | expr ';' exprs          { $1 : $3 }

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

      | '(' ')'                 { (ExprTuple [], tokenPosn $1 <-> tokenPosn $2) }
      | '(' args ')'            { (ExprTuple $2, tokenPosn $1 <-> tokenPosn $3) }
      | '{' exprs '}'           { (ExprBlock $2, tokenPosn $1 <-> tokenPosn $3)}
      
      | '-' int %prec NEG       { parseNInt $1 $2 }

      | var id '=' expr         { parseVar $1 $2 PatWild $4 }
      | var id ':' pat '=' expr         { parseVar $1 $2 $4 $6 }
      | const id '=' expr       { parseConst $1 $2 PatWild $4 }
      | const id ':' pat '=' expr       { parseConst $1 $2 $4 $6 }

      | id ':=' expr            { parseAssign $1 $3 }
      | id                      { parseId $1 }

      | box expr                { (ExprBox (ExprLit (LitPat PatWild), undefined) $2, tokenPosn $1 <-> snd $2) }
      | box '[' expr ']' expr   { (ExprBox $3 $5, tokenPosn $1 <-> snd $5) }
      | unbox expr              { parseUnOp Unbox $1 $2 }
      | expr '<-' expr          { (ExprSetBox $1 $3, ($1 <|> $3)) }

      | if expr then expr else expr { (ExprIfElse $2 $4 $6, tokenPosn $1 <-> snd $6) }
      | func id '(' ')' '->' expr      { (\(TokenPosn (TokId id) _) -> (ExprFunc (Just id) [] $6, tokenPosn $1 <-> snd $6)) $2 } 
      | func id '(' ids ')' '->' expr  { (\(TokenPosn (TokId id) _) -> (ExprFunc (Just id) $4 $7, tokenPosn $1 <-> snd $7)) $2 } 
      | func '(' ')' '->' expr       { (ExprFunc Nothing [] $5, tokenPosn $1 <-> snd $5) }
      | func '(' ids ')' '->' expr   { (ExprFunc Nothing $3 $6, tokenPosn $1 <-> snd $6) }

      | expr apply expr         { (ExprApply $1 $3, snd $1 <-> snd $3) }

      | true                    { (ExprLit (LitBool True), tokenPosn $1) }
      | false                   { (ExprLit (LitBool False), tokenPosn $1) }

      | '_'                     { (ExprLit (LitPat PatWild), tokenPosn $1) }
      | int_t                   { (ExprLit (LitPat PatIntT), tokenPosn $1) }
      | bool_t                  { (ExprLit (LitPat PatBoolT), tokenPosn $1) }
      | box_t '[' pat ']'       { (ExprLit (LitPat (PatBoxT $3)), tokenPosn $1 <-> tokenPosn $4) }
      | func_t                  { (ExprLit (LitPat PatFuncT), tokenPosn $1) }
      | expr '?'                { (ExprUnOp Typeof $1, snd $1 <-> tokenPosn $2) }

apply :  %prec APPLY   {}

args : expr                     { [$1] }
     | expr ',' args            { $1 : $3 }

ids : id                        { (\(TokenPosn (TokId id) _) -> [Param id PatWild]) $1 }
    | id ',' ids                { parseParams $1 $3 }

pat : '_'                     { PatWild }
    | int_t                   { PatIntT }
    | bool_t                  { PatBoolT }
    | box_t '[' pat ']'       { PatBoxT $3 }
    | func_t                  { PatFuncT }

{

parseInt :: TokenPosn -> ExprPosn
parseInt (TokenPosn (TokInt int) pos) =
  (ExprLit (LitInt int), pos)

parseNInt :: TokenPosn -> TokenPosn -> ExprPosn
parseNInt (TokenPosn _ pos1) (TokenPosn (TokInt int) pos2) =
  (ExprLit (LitInt $ -int), pos1 <-> pos2)

parseUnOp :: UnOp -> TokenPosn -> ExprPosn -> ExprPosn
parseUnOp op (TokenPosn _ pos1) expr@(_, pos2) =
  (ExprUnOp op expr, pos1 <-> pos2)

parseVar :: TokenPosn -> TokenPosn -> PatT -> ExprPosn -> ExprPosn
parseVar (TokenPosn _ pos1) (TokenPosn (TokId id) _) pat expr@(_, pos2) =
  (ExprVar id pat expr, pos1 <-> pos2)

parseConst :: TokenPosn -> TokenPosn -> PatT -> ExprPosn -> ExprPosn
parseConst (TokenPosn _ pos1) (TokenPosn (TokId id) _) pat expr@(_, pos2) =
  (ExprConst id pat expr, pos1 <-> pos2)

parseId :: TokenPosn -> ExprPosn
parseId (TokenPosn (TokId id) pos) = (ExprId id, pos)

parseParams :: TokenPosn -> [Param] -> [Param]
parseParams tok@(TokenPosn (TokId id) _) ps = if elem id (map paramName ps)
  then error ("Duplicate parameter name in function definition: " ++ id)
  else (Param id PatWild):ps

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
