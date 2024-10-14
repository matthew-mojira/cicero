module Type where

data Type = TypeInt
          | TypeBool
          | TypeType Type
          deriving Eq

instance Show Type where
  show TypeInt  = "int"
  show TypeBool = "bool"
  show (TypeType t) = concat ["type[", show t, "]"]

(<:) :: Type -> Type -> Bool
(<:) = (==)
