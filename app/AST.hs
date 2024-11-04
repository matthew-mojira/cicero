module AST where

import Data.List

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
  | ExprTry    { try     :: ExprPosn
               , catch   :: ExprPosn
               , finally :: ExprPosn
               }
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
  deriving Eq

instance Show BinOp where
  show Add = "+"
  show Sub = "-"
  show Mult = "*"
  show Exp = "^"
  show Div = "/"
  show LAnd = "and"
  show LOr = "or"
  show Eq = "="
  show Neq = "/="
  show Le = "<"
  show Leq = "<="
  show Ge = ">"
  show Geq = ">="

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
--    concat ["(Lit ", show val, ")"]
  show (ExprUnOp op (expr, _)) =
    concat ["(UnOp ", show op, " ", show expr, ")"]
  show (ExprBinOp op (expr1, _) (expr2, _)) =
    concat [show expr1, " ", show op, " ", show expr2]
  show (ExprIfElse (expr1, _) (expr2, _) (expr3, _)) =
    concat ["(if ", show expr1, " then ", show expr2, " else ", show expr3]
  show (ExprVar id pat (expr, _)) =
    concat ["(Var ", show id, " ", show pat, " ", show expr, ")"]
  show (ExprConst id pat (expr, _)) =
    concat ["(Const ", show id, " ", show pat, " ", show expr, ")"]
  show (ExprId id) = id
--    concat ["(Id ", id, ")"]
  show (ExprAssign id (expr, _)) =
    concat ["(Assign ", id, " ", show expr, ")"]
  show (ExprBox pat (expr, _)) =
    concat ["(Box ", show pat, " ", show expr, ")"]
  show (ExprSetBox (expr1, _) (expr2, _)) =
    concat ["(SetBox ", show expr1, " ", show expr2, ")"]
  show (ExprBlock exprs) =
    concat ["{", concatMap (\(e, _) -> show e ++ ";") exprs, "}"]
  show (ExprFunc name params (expr, _) _) =
    concat ["(Func ", show name, " ", show params, " ", show expr, ")"]
  show (ExprWhile (guard, _) (body, _)) =
    concat ["while ", show guard, " do ", show body]
  show (ExprTuple exprs) =
    concat ["(", intercalate "," (map (\(e, _) -> show e) exprs), ")"]
  show (ExprApply func (expr, _)) =
    concat [show (fst func), " [", show expr, "]"]
  show (ExprTry (tryE, _) (catchE, _) (finE, _)) =
    concat ["try ", show tryE, " catch ", show catchE]

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
