module AST where

import Value

type Prog = Expr

data Expr
  = ExprLit Value
  | ExprUnOp UnOp Expr
  | ExprBinOp BinOp Expr Expr

data UnOp =
  LNot

data BinOp
  = Add
  | Sub
  | Mult
  | Div
  | LAnd
  | LOr
  | Eq
  | Neq
  | Le
  | Leq
  | Ge
  | Geq

binOpInt :: BinOp -> Bool
binOpInt Add  = True
binOpInt Sub  = True
binOpInt Mult = True
binOpInt Div  = True
binOpInt _    = False

binOpEq :: BinOp -> Bool
binOpEq Eq  = True
binOpEq Neq = True
binOpEq _   = False

binOpComp :: BinOp -> Bool
binOpComp Le  = True
binOpComp Leq = True
binOpComp Ge  = True
binOpComp Geq = True
binOpComp _   = False

instance Show Expr where
  show (ExprLit val) = show val
  show (ExprBinOp op expr1 expr2) =
    "(" ++ show expr1 ++ " " ++ show op ++ " " ++ show expr2 ++ ")"

instance Show BinOp where
  show Add = "+"
  show Sub = "-"
  show Mult = "*"
  show Div = "/"
