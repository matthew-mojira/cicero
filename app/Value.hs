module Value where

import Type

data Value = ValInt  Integer
           | ValBool Bool
           | ValBox  Int  -- pointer
           | ValType Type
           | ValVoid
           deriving Eq

instance Show Value where
  show (ValInt int)   = show int
  show (ValBool bool) = if bool then "true" else "false"
  show (ValBox idx)   = concat ["box[#", show idx, "]"]
  show (ValType typ)  = concat ["type[", show typ, "]"]
  show ValVoid        = "void"

typeof :: Value -> Type
typeof (ValInt _)  = TypeInt
typeof (ValBool _) = TypeBool
typeof (ValBox _)  = TypeBox TypeAny
typeof (ValType t) = TypeType t
typeof ValVoid     = TypeVoid
