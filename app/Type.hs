module Type where

data Type = TypeInt
          | TypeBool
          | TypeType
          deriving Eq

instance Show Type where
  show TypeInt  = "int"
  show TypeBool = "bool"
  show TypeType = "type"

(<:) :: Type -> Type -> Bool
(<:) = (==)
