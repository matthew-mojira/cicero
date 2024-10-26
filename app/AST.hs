module AST where

import Lexer (AlexPosn, Posn)

type Prog = [ExprPosn]

type ExprPosn = (Expr, Posn)

data Expr
  = ExprLit    Lit
  | ExprUnOp   UnOp ExprPosn
  | ExprBinOp  BinOp ExprPosn ExprPosn
  | ExprIfElse ExprPosn ExprPosn ExprPosn
  | ExprVar    String PatT ExprPosn
  | ExprConst  String PatT ExprPosn
  | ExprId     String
  | ExprAssign String ExprPosn
  | ExprBox    { boxPat :: ExprPosn, boxInit :: ExprPosn}
  | ExprSetBox ExprPosn ExprPosn
  | ExprBlock  [ExprPosn]
  | ExprWhile  { guard :: ExprPosn, body :: ExprPosn }
  | ExprFunc   { funcName   :: (Maybe String)
               , funcParams :: [Param]
               , funcBody   :: ExprPosn
               , funcRetPat :: Maybe [PatT]
               }
  | ExprApply  ExprPosn ExprPosn
  | ExprTuple  [ExprPosn]
  deriving Eq

data Param = Param { paramName :: String, paramPat :: PatT }
               deriving (Eq, Show)

data Lit = LitInt  Integer
         | LitBool Bool
         | LitPat  PatT
         deriving Eq

data PatT = PatIntT
          | PatBoolT
          | PatBoxT PatT
          | PatFuncT
          | PatTypeT
          | PatWild
          deriving (Eq, Show)

data UnOp = LNot
          | Unbox
          | Typeof
          deriving (Eq, Show)

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
  deriving (Eq, Show)

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
  show (ExprLit val) =
    concat ["(Lit ", show val, ")"]
  show (ExprUnOp op (expr, _)) =
    concat ["(UnOp ", show op, " ", show expr, ")"]
  show (ExprBinOp op (expr1, _) (expr2, _)) =
    concat ["(BinOp ", show op, " ", show expr1, " ", show expr2, ")"]
  show (ExprIfElse (expr1, _) (expr2, _) (expr3, _)) =
    concat ["(IfElse ", show expr1, " ", show expr2, " ", show expr3, ")"]
  show (ExprVar id pat (expr, _)) =
    concat ["(Var ", show id, " ", show pat, " ", show expr, ")"]
  show (ExprConst id pat (expr, _)) =
    concat ["(Const ", show id, " ", show pat, " ", show expr, ")"]
  show (ExprId id) =
    concat ["(Id ", show id, ")"]
  show (ExprAssign id (expr, _)) =
    concat ["(Assign ", id, " ", show expr, ")"]
  show (ExprBox pat (expr, _)) =
    concat ["(Box ", show pat, " ", show expr, ")"]
  show (ExprSetBox (expr1, _) (expr2, _)) =
    concat ["(SetBox ", show expr1, " ", show expr2, ")"]
  show (ExprBlock exprs) =
    concat ["(Block ", show $ map (show . fst) exprs, ")"]
  show (ExprFunc name params (expr, _) _) =
    concat ["(Func ", show name, " ", show params, " ", show expr, ")"]
  show (ExprWhile (guard, _) (body, _)) =
    concat ["(While ", show guard, " ", show body, ")"]
  show (ExprTuple exprs) =
    concat ["(Tuple ", show $ map (show . fst) exprs, ")"]
  show (ExprApply func (expr, _)) =
    concat ["(Apply ", show (fst func), " ", show expr, ")"]

instance Show Lit where
  show (LitBool bool) = show bool
  show (LitInt int)   = show int
  show (LitPat pat)   = show pat

--instance Show UnOp where
--  show LNot   = "not"
--  show Box    = "box"
--  show Unbox  = "unbox"
--  show Typeof = "typeof"

--instance Show BinOp where
--  show Add  = "+"
--  show Sub  = "-"
--  show Mult = "*"
--  show Div  = "/"
--  show LAnd = "and"
--  show LOr  = "or"
--  show Eq   = "="
--  show Neq  = "!="
--  show Le   = "<"
--  show Leq  = "<="
--  show Ge   = ">"
--  show Geq  = ">="
