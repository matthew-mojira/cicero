module Value where

data Value = ValInt Integer

instance Show Value where
  show (ValInt i) = show i
