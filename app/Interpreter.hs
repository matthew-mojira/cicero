module Interpreter where

import Control.Monad
import Control.Monad.Trans.State

import AST
import Value

type Env = [(String, Value)]

type Error = String

-- type Prog = Expr
eval :: Prog -> Either Error Value
eval prog = evalStateT (evalExpr prog) []

evalExpr :: ExprPosn -> StateT Env (Either Error) Value
evalExpr ((ExprLit value), _) = return value
evalExpr ((ExprUnOp LNot expr), _) = do
  x <- evalExpr expr
  let ValBool bool = x
  return $ ValBool $ not bool
evalExpr ((ExprBinOp op expr1 expr2), _)
  | binOpEq op = do
    val1 <- evalExpr expr1
    val2 <- evalExpr expr2
    let op' =
          case op of
            Eq -> (==)
            Neq -> (/=)
    return $ ValBool $ op' val1 val2
  | binOpComp op = do
    val1 <- evalExpr expr1
    val2 <- evalExpr expr2
    let ValInt int1 = val1
    let ValInt int2 = val2
    let op' =
          case op of
            Le -> (<)
            Leq -> (<=)
            Ge -> (>)
            Geq -> (>=)
    return $ ValBool $ op' int1 int2
  | binOpInt op = do
    val1 <- evalExpr expr1
    val2 <- evalExpr expr2
    let ValInt int1 = val1
    let ValInt int2 = val2
    let op' =
          case op of
            Add -> (+)
            Sub -> (-)
            Mult -> (*)
            Exp -> (^)
            Div -> div
    return $ ValInt $ op' int1 int2
  | binOpBool op = do
    val1 <- evalExpr expr1
    val2 <- evalExpr expr2
    let ValBool bool1 = val1
    let ValBool bool2 = val2
    let op' =
          case op of
            LAnd -> (&&)
            LOr -> (||)
    return $ ValBool $ op' bool1 bool2
