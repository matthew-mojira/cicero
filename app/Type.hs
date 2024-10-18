module Type where

data Type = TypeInt
          | TypeBool
          | TypeBox
          | TypeVoid
          | TypeType
          | TypeFunc Int  -- number of params
          deriving Eq

instance Show Type where
  show TypeInt      = "int"
  show TypeBool     = "bool"
  show TypeVoid     = "void"
  show TypeBox      = "box"
  show TypeType     = "type"
  show (TypeFunc i) = concat ["func[@", show i, "]"]

(<:) :: Type -> Type -> Bool
(<:) = (==)
