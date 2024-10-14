module Type where

data Type = TypeInt
          | TypeBool
          | TypeBox Type -- interior element type
          | TypeAny
          | TypeType
          deriving Eq

instance Show Type where
  show TypeInt      = "int"
  show TypeBool     = "bool"
  show (TypeBox t)  = concat ["box[", show t, "]"]
  show TypeType     = "type"
  show TypeAny      = "?"

(<:) :: Type -> Type -> Bool
(<:) = (==)
