module AST where

import Value

type Prog = Expr

data Expr = ExprLit Value

instance Show Expr where
  show (ExprLit v) = show v
