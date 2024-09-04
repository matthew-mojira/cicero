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
binOpComp Eq  = True
binOpComp Neq = True
binOpComp Le  = True
binOpComp Leq = True
binOpComp Ge  = True
binOpComp Geq = True
binOpComp _   = False

binOpBool :: BinOp -> Bool
binOpBool LAnd = True
binOpBool LOr  = True
binOpBool _    = False

instance Show Expr where
  show (ExprLit val) = show val
  show (ExprUnOp op expr) = show op ++ " " ++ show expr
  show (ExprBinOp op expr1 expr2) =
    "(" ++ show expr1 ++ " " ++ show op ++ " " ++ show expr2 ++ ")"

instance Show UnOp where
  show LNot = "not"

instance Show BinOp where
  show Add  = "+"
  show Sub  = "-"
  show Mult = "*"
  show Div  = "/"
  show LAnd = "and"
  show LOr  = "or"
  show Eq   = "="
  show Neq  = "!="
  show Le   = "<"
  show Leq  = "<="
  show Ge   = ">"
  show Geq  = ">="
