module Type where

data Type = TypeInt
          | TypeBool
          deriving Eq

instance Show Type where
  show TypeInt  = "int"
  show TypeBool = "bool"

(<:) :: Type -> Type -> Bool
(<:) = (==)
