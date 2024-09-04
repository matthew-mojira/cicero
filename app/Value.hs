module Value where

data Value = ValInt Integer
           | ValBool Bool
           deriving Eq

instance Show Value where
  show (ValInt int) = show int
  show (ValBool bool) = if bool then "true" else "false"
