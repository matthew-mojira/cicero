module Eval where

import AST
import Value

-- type Prog = Expr
eval :: Prog -> Value
eval prog = evalExpr prog

evalExpr :: Expr -> Value
evalExpr (ExprLit value) = value
