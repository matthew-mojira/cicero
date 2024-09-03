module Typechecker where

import AST
import Type
import Value

typeof :: Prog -> Either String Type
typeof = typeofExpr

typeofExpr :: Expr -> Either String Type
typeofExpr (ExprLit (ValInt _)) = return TypeInt
typeofExpr (ExprLit (ValBool _)) = return TypeBool
typeofExpr (ExprUnOp LNot expr) = do
  type1 <- typeofExpr expr
  if type1 == TypeBool
    then return TypeBool
    else typeError
typeofExpr (ExprBinOp op expr1 expr2)
  | binOpInt op = do
    type1 <- typeofExpr expr1
    type2 <- typeofExpr expr2
    if type1 == TypeInt && type2 == TypeInt
      then return TypeInt
      else typeError
  | otherwise = do
    type1 <- typeofExpr expr1
    type2 <- typeofExpr expr2
    if type1 == TypeBool && type2 == TypeBool
      then return TypeBool
      else typeError

typeError :: Either String a
typeError = Left "type error"
