module AST where

import Value
import Lexer (AlexPosn, Posn)

type Prog = ExprPosn

type ExprPosn = (Expr, Posn)

data Expr
  = ExprLit    Value
  | ExprUnOp   UnOp ExprPosn
  | ExprBinOp  BinOp ExprPosn ExprPosn
  | ExprIfElse ExprPosn ExprPosn ExprPosn
  | ExprVar    String ExprPosn -- omit type
  | ExprConst  String ExprPosn -- omit type
  | ExprId     String
  | ExprAssign String ExprPosn
  | ExprSetBox ExprPosn ExprPosn
  | ExprBlock  [ExprPosn]
  | ExprFunc   [String] ExprPosn]

data UnOp = LNot
          | Box
          | Unbox
          | Typeof

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
  show (ExprIfElse (expr1, _) (expr2, _) (expr3, _)) =
    unwords ["if", show expr1, "then", show expr2, "else", show expr3]
  show (ExprVar id (expr, _)) = unwords ["var", id, "=", show expr]
  show (ExprConst id (expr, _)) = unwords ["const", id, "=", show expr]
  show (ExprId id) = id
  show (ExprAssign id expr) = unwords [id, ":=", show expr]
  show (ExprSetBox expr1 expr2) = unwords [show expr1, "<-", show expr2]
  show (ExprBlock exprs) =
    unlines $ ["{"] ++ map (show . fst) exprs ++ ["}"]

instance Show UnOp where
  show LNot   = "not"
  show Box    = "box"
  show Unbox  = "unbox"
  show Typeof = "typeof"

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
