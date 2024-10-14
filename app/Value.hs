module Value where

import Type

data Value = ValInt Integer
           | ValBool Bool
           | ValType Type
           deriving Eq

instance Show Value where
  show (ValInt int) = show int
  show (ValBool bool) = if bool then "true" else "false"
  show (ValType typ)  = concat ["type[", show typ, "]"]

typeof :: Value -> Type
typeof (ValInt _)  = TypeInt
typeof (ValBool _) = TypeBool
typeof (ValType t) = TypeType t
