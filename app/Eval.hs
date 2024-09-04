module Eval where

import AST
import Value

-- type Prog = Expr
eval :: Prog -> Value
eval prog = evalExpr prog

evalExpr :: Expr -> Value
evalExpr (ExprLit value) = value
evalExpr (ExprUnOp LNot expr) =
  let ValBool bool = evalExpr expr
   in ValBool $ not bool
evalExpr (ExprBinOp op expr1 expr2)
  | binOpEq op =
    let val1 = evalExpr expr1
        val2 = evalExpr expr2
        op' =
          case op of
            Eq -> (==)
            Neq -> (/=)
     in ValBool $ op' val1 val2
  | binOpComp op =
    let ValInt int1 = evalExpr expr1
        ValInt int2 = evalExpr expr2
        op' =
          case op of
            Le -> (<)
            Leq -> (<=)
            Ge -> (>)
            Geq -> (>=)
     in ValBool $ op' int1 int2
  | binOpInt op =
    let ValInt int1 = evalExpr expr1
        ValInt int2 = evalExpr expr2
        op' =
          case op of
            Add -> (+)
            Sub -> (-)
            Mult -> (*)
            Div -> div
     in ValInt $ op' int1 int2
  | binOpBool op =
    let ValBool bool1 = evalExpr expr1
        ValBool bool2 = evalExpr expr2
        op' =
          case op of
            LAnd -> (&&)
            LOr -> (||)
     in ValBool $ op' bool1 bool2
