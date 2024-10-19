module Type where

data Type = TypeInt
          | TypeBool
          | TypeBox
          | TypeVoid
          | TypeType
          | TypeFunc
          deriving Eq

instance Show Type where
  show TypeInt      = "int"
  show TypeBool     = "bool"
  show TypeVoid     = "void"
  show TypeBox      = "box"
  show TypeType     = "type"
  show TypeFunc     = "func"

(<:) :: Type -> Type -> Bool
(<:) = (==)
