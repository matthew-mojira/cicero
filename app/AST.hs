module AST where

import Value

type Prog = Expr

data Expr = ExprLit Value
          | ExprAdd Expr Expr

instance Show Expr where
  show (ExprLit val) = show val
  show (ExprAdd expr1 expr2) = show expr1 ++ " + " ++ show expr2
