module Value where

import AST
import Type

data Value = ValInt  Integer
           | ValBool Bool
           | ValBox  Int  -- pointer
           | ValType Type
           | ValVoid
           | ValFunc [String] ExprPosn
           deriving Eq

instance Show Value where
  show (ValInt int)   = show int
  show (ValBool bool) = if bool then "true" else "false"
  show (ValBox idx)   = concat ["box[#", show idx, "]"]
  show (ValType typ)  = concat ["type[", show typ, "]"]
  show ValVoid        = "void"
  show (ValFunc ps _) = concat ["func[@", show (length ps), "]"]
