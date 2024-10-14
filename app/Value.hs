module Value where

import Type

data Value = ValInt  Integer
           | ValBool Bool
           | ValVar  Int  -- pointer
           deriving Eq

instance Show Value where
  show (ValInt int)   = show int
  show (ValBool bool) = if bool then "true" else "false"
  show (ValVar idx)   = concat ["var[#", show idx, "]"]

typeof :: Value -> Type
typeof (ValInt _)  = TypeInt
typeof (ValBool _) = TypeBool
typeof (ValVar _)  = TypeVar
