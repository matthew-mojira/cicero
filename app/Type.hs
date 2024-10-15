module Type where

data Type = TypeInt
          | TypeBool
          | TypeBox Type -- interior element type
          | TypeVoid
          | TypeType
          | TypeAny
          | TypeFunc Int  -- number of params
          deriving Eq

instance Show Type where
  show TypeInt      = "int"
  show TypeBool     = "bool"
  show TypeVoid     = "void"
  show (TypeBox t)  = concat ["box[", show t, "]"]
  show TypeType     = "type"
  show TypeAny      = "any"
  show (TypeFunc i) = concat ["func[", show i, "]"]

(<:) :: Type -> Type -> Bool
(<:) = (==)
