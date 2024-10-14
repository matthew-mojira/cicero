module Type where

data Type = TypeInt
          | TypeBool
          | TypeBox Type -- interior element type
          | TypeVoid
          | TypeAny
          | TypeType Type
          deriving Eq

instance Show Type where
  show TypeInt      = "int"
  show TypeBool     = "bool"
  show TypeVoid     = "void"
  show (TypeBox t)  = concat ["box[", show t, "]"]
  show (TypeType t) = concat ["type[", show t, "]"]
  show TypeAny      = "?"

(<:) :: Type -> Type -> Bool
(<:) = (==)
