module AST where

import Value

type Prog = Expr

data Expr = ExprLit Value
          | ExprBinOp BinOp Expr Expr

data BinOp = Add | Sub | Mult | Div

instance Show Expr where
  show (ExprLit val) = show val
  show (ExprBinOp op expr1 expr2) = "(" ++ show expr1 ++ " " ++ show op ++ " " ++ show expr2 ++ ")"

instance Show BinOp where
  show Add  = "+"
  show Sub  = "-"
  show Mult = "*"
  show Div  = "/"
