module Type where

data Type = TypeInt
          | TypeBool
          | TypeBox Type -- interior element type
          | TypeAny
          | TypeType Type
          deriving Eq

instance Show Type where
  show TypeInt      = "int"
  show TypeBool     = "bool"
  show (TypeBox t)  = concat ["box[", show t, "]"]
  show (TypeType t) = concat ["type[", show t, "]"]
  show TypeAny      = "?"

(<:) :: Type -> Type -> Bool
(<:) = (==)
