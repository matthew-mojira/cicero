module Typechecker where

import Lexer (runAlex, alexError, Alex, AlexPosn(AlexPn))

import AST
import Type
import Value

typeCheck :: Prog -> Either String Type
typeCheck prog = runAlex "" (typeofExpr prog)

typeofExpr :: ExprPosn -> Alex Type
typeofExpr (ExprLit (ValInt _), pos) = return TypeInt
typeofExpr (ExprLit (ValBool _), pos) = return TypeBool
typeofExpr (ExprUnOp LNot expr, pos) = do
  type1 <- typeofExpr expr
  if type1 == TypeBool
    then return TypeBool
    else typeError pos
typeofExpr (ExprBinOp op expr1 expr2, pos)
  | binOpBool op = do
    type1 <- typeofExpr expr1
    type2 <- typeofExpr expr2
    if type1 == TypeBool && type2 == TypeBool
      then return TypeBool
      else typeError pos
  | binOpEq op = do
    type1 <- typeofExpr expr1
    type2 <- typeofExpr expr2
    if type1 == type2
      then return TypeBool
      else typeError pos
  | binOpComp op = do
    type1 <- typeofExpr expr1
    type2 <- typeofExpr expr2
    if type1 == TypeInt && type2 == TypeInt
      then return TypeBool
      else typeError pos
  | binOpInt op = do
    type1 <- typeofExpr expr1
    type2 <- typeofExpr expr2
    if type1 == TypeInt && type2 == TypeInt
      then return TypeInt
      else typeError pos

typeError :: (AlexPosn, AlexPosn) -> Alex a
typeError (AlexPn _ line col, _) = alexError $ "type error at line " ++ show line ++ ", column " ++ show col
