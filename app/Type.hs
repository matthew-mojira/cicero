module Type where

data Type = TypeInt
          | TypeBool
          | TypeBox Type -- interior element type
          | TypeVoid
          | TypeType
          | TypeAny
          deriving Eq

instance Show Type where
  show TypeInt      = "int"
  show TypeBool     = "bool"
  show TypeVoid     = "void"
  show (TypeBox t)  = concat ["box[", show t, "]"]
  show TypeType     = "type"
  show TypeAny      = "any"

(<:) :: Type -> Type -> Bool
(<:) = (==)
