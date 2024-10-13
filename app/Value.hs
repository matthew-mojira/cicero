module Value where

import Type

data Value = ValInt Integer
           | ValBool Bool
           deriving Eq

instance Show Value where
  show (ValInt int) = show int
  show (ValBool bool) = if bool then "true" else "false"

typeof :: Value -> Type
typeof (ValInt _)  = TypeInt
typeof (ValBool _) = TypeBool
