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
%left  where
%right else while do catch
%right ':=' '<-'
%left  or
%left  and
%left  '=' '!='
%left  '<' '<=' '>' '>='
%left  '+' '-'
%left  '*' '/'
%right '**' '^'
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
      str             { TokenPosn (TokStr _) (_, _) }
      char            { TokenPosn (TokChar _) (_, _) }

      func            { TokenPosn TokFunc (_, _) }

      true            { TokenPosn TokTrue (_, _) }
      false           { TokenPosn TokFalse (_, _) }
      and             { TokenPosn TokAnd (_, _) }
      or              { TokenPosn TokOr (_, _) }
      not             { TokenPosn TokNot (_, _) }
      if              { TokenPosn TokIf (_, _) }
      then            { TokenPosn TokThen (_, _) }
      else            { TokenPosn TokElse (_, _) }
      while           { TokenPosn TokWhile (_, _) }
      do              { TokenPosn TokDo (_, _) }

      var             { TokenPosn TokVar (_, _) }
      const           { TokenPosn TokConst (_, _) }
      box             { TokenPosn TokBox (_, _) }
      unbox           { TokenPosn TokUnbox (_, _) }

      try             { TokenPosn TokTry (_, _) }
      catch           { TokenPosn TokCatch (_, _) }
      finally         { TokenPosn TokFinally (_, _) }
      print           { TokenPosn TokPrint (_, _) }
      scan            { TokenPosn TokScan (_, _) }

      int_t           { TokenPosn TokIntT (_, _) }
      bool_t          { TokenPosn TokBoolT (_, _) }
      box_t           { TokenPosn TokBoxT (_, _) }
      type_t          { TokenPosn TokTypeT (_, _) }
      func_t          { TokenPosn TokFuncT (_, _) }
      void            { TokenPosn TokVoid (_, _) }

      where           { TokenPosn TokWhere (_, _) }
%%

exprs :                         { [] }
      | expr ';' exprs          { $1 : $3 }

expr  : int                     { parseInt $1 }
      | str                     { parseString $1 }
      | char                    { parseChar $1 }
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
      
      | var id '=' expr             { parseVar $1 $2 AnyP $4 }
      | var id ':' pat '=' expr     { parseVar $1 $2 $4 $6 }
      | const id '=' expr           { parseConst $1 $2 AnyP $4 }
      | const id ':' pat '=' expr   { parseConst $1 $2 $4 $6 }

      | id ':=' expr            { parseAssign $1 $3 }
      | id                      { parseId $1 }

      | unbox expr              { parseUnOp Unbox $1 $2 }
      | expr '<-' expr          { (ExprSetBox $1 $3, ($1 <|> $3)) }

      | if expr then expr else expr { (ExprIfElse $2 $4 $6, tokenPosn $1 <-> snd $6) }

      | while expr do expr      { (ExprWhile $2 $4, tokenPosn $1 <-> snd $4) }

      | try expr catch expr     { (ExprTry $2 $4 nop, tokenPosn $1 <-> snd $4) }

      | func id '('        ')'          '->' expr  { (\(TokenPosn (TokId id) _) -> (ExprFunc (Just id) [] $6 Nothing, tokenPosn $1 <-> snd $6)) $2 } 
      | func id '(' params ')'          '->' expr  { (\(TokenPosn (TokId id) _) -> (ExprFunc (Just id) $4 $7 Nothing , tokenPosn $1 <-> snd $7)) $2 } 
      | func    '('        ')'          '->' expr  { (ExprFunc Nothing [] $5 Nothing, tokenPosn $1 <-> snd $5) }
      | func    '(' params ')'          '->' expr  { (ExprFunc Nothing $3 $6 Nothing, tokenPosn $1 <-> snd $6) }
      | func id '('        ')' ':' void '->' expr  { (\(TokenPosn (TokId id) _) -> (ExprFunc (Just id) [] $8 (Just []), tokenPosn $1 <-> snd $8)) $2 } 
      | func id '(' params ')' ':' void '->' expr  { (\(TokenPosn (TokId id) _) -> (ExprFunc (Just id) $4 $9 (Just []), tokenPosn $1 <-> snd $9)) $2 } 
      | func    '('        ')' ':' void '->' expr  { (ExprFunc Nothing [] $7 (Just []), tokenPosn $1 <-> snd $7) }
      | func    '(' params ')' ':' void '->' expr  { (ExprFunc Nothing $3 $8 (Just []), tokenPosn $1 <-> snd $8) }
      | func id '('        ')' ':' pats '->' expr  { (\(TokenPosn (TokId id) _) -> (ExprFunc (Just id) [] $8 (Just $6), tokenPosn $1 <-> snd $8)) $2 } 
      | func id '(' params ')' ':' pats '->' expr  { (\(TokenPosn (TokId id) _) -> (ExprFunc (Just id) $4 $9 (Just $7), tokenPosn $1 <-> snd $9)) $2 } 
      | func    '('        ')' ':' pats '->' expr  { (ExprFunc Nothing [] $7 (Just $5), tokenPosn $1 <-> snd $7) }
      | func    '(' params ')' ':' pats '->' expr  { (ExprFunc Nothing $3 $8 (Just $6), tokenPosn $1 <-> snd $8) }

      | expr apply expr %prec APPLY    { (ExprApply $1 $3, snd $1 <-> snd $3) }

      | print '(' expr ')'      { parseUnOp Print $1 $3 }
      | scan                    { (ExprZeroOp Scan, tokenPosn $1) }

      | true                    { (ExprLit (LitBool True), tokenPosn $1) }
      | false                   { (ExprLit (LitBool False), tokenPosn $1) }

      | int_t                   { (ExprLit (LitType IntT), tokenPosn $1) }
      | bool_t                  { (ExprLit (LitType BoolT), tokenPosn $1) }
      | func_t                  { (ExprLit (LitType FuncT), tokenPosn $1) }
      | type_t                  { (ExprLit (LitType TypeT), tokenPosn $1) }
      | expr '?'                { (ExprUnOp Typeof $1, snd $1 <-> tokenPosn $2) }

apply : %prec APPLY {}

args : expr                     { [$1] }
     | expr ',' args            { $1 : $3 }

pats : pat                    { [$1] }
     | pat ',' pats           { $1 : $3 }

params : param                { [$1] }
       | param ',' params     { parseParams $1 $3 }

param : id                    { (\(TokenPosn (TokId id) _) -> (Param id AnyP)) $1 }
      | id ':' pat            { (\(TokenPosn (TokId id) _) -> (Param id $3)) $1 }

pat  : '_'                     { AnyP }        
     | patT                    { TypeP $1 Nothing }
     | patT where expr         { TypeP $1 (Just $3) }

patT : int_t                   { IntT  }
     | bool_t                  { BoolT }
     | func_t                  { FuncT }
     | type_t                  { TypeT }

typeT : {}

{

nop = (ExprBlock [], undefined)

parseInt :: TokenPosn -> ExprPosn
parseInt (TokenPosn (TokInt int) pos) =
  (ExprLit (LitInt int), pos)

parseString :: TokenPosn -> ExprPosn
parseString (TokenPosn (TokStr str) pos) =
  (ExprLit (LitStr str), pos)

parseChar :: TokenPosn -> ExprPosn
parseChar (TokenPosn (TokChar char) pos) =
  (ExprLit (LitChar char), pos)

parseUnOp :: UnOp -> TokenPosn -> ExprPosn -> ExprPosn
parseUnOp op (TokenPosn _ pos1) expr@(_, pos2) =
  (ExprUnOp op expr, pos1 <-> pos2)

parseVar :: TokenPosn -> TokenPosn -> Pattern -> ExprPosn -> ExprPosn
parseVar (TokenPosn _ pos1) (TokenPosn (TokId id) _) pat expr@(_, pos2) =
  (ExprVar id pat expr, pos1 <-> pos2)

parseConst :: TokenPosn -> TokenPosn -> Pattern -> ExprPosn -> ExprPosn
parseConst (TokenPosn _ pos1) (TokenPosn (TokId id) _) pat expr@(_, pos2) =
  (ExprConst id pat expr, pos1 <-> pos2)

parseId :: TokenPosn -> ExprPosn
parseId (TokenPosn (TokId id) pos) = (ExprId id, pos)

parseParams :: Param -> [Param] -> [Param]
parseParams p@(Param id _) ps = if elem id (map paramName ps)
  then error ("Duplicate parameter name in function definition: " ++ id)
  else p:ps

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
