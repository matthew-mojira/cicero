module AST where

import Value
import Lexer (AlexPosn)

type Prog = ExprPosn

type ExprPosn = (Expr, (AlexPosn, AlexPosn))

data Expr
  = ExprLit Value
  | ExprUnOp UnOp ExprPosn
  | ExprBinOp BinOp ExprPosn ExprPosn

data UnOp =
  LNot

data BinOp
  = Add
  | Sub
  | Mult
  | Exp
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
binOpInt Exp  = True
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
  show (ExprUnOp op (expr, _)) = show op ++ " " ++ show expr
  show (ExprBinOp op (expr1, _) (expr2, _)) =
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
