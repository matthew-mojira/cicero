module Type where

data Type = TypeInt
          | TypeBool
          | TypeBox Type -- interior element type
          | TypeAny
          deriving Eq

instance Show Type where
  show TypeInt     = "int"
  show TypeBool    = "bool"
  show (TypeBox t) = concat ["box[", show t, "]"]
  show TypeAny     = "?"

(<:) :: Type -> Type -> Bool
(<:) = (==)
