module Type where

data Type = TypeInt
          | TypeBool
          | TypeBox
          | TypeVoid
          | TypeType
          deriving Eq

instance Show Type where
  show TypeInt      = "int"
  show TypeBool     = "bool"
  show TypeVoid     = "void"
  show TypeBox      = "box"
  show TypeType     = "type"

(<:) :: Type -> Type -> Bool
(<:) = (==)
