module Type where

data Type = TypeInt
          | TypeBool
          | TypeBox
          | TypeFunc
          | TypeStr
          | TypeChar
          | TypeType
          | TypeErr
          deriving Eq

instance Show Type where
  show TypeInt  = "int"
  show TypeBool = "bool"
  show TypeBox  = "box"
  show TypeFunc = "func"
  show TypeStr  = "str"
  show TypeChar = "char"
  show TypeType = "type"
  show TypeErr  = "error"

(<:) :: Type -> Type -> Bool
(<:) = (==)
