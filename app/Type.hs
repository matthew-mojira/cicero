module Type where

data Type = TypeInt
          | TypeBool
          | TypeBox
          | TypeType
          | TypeFunc
          | TypeStr
          | TypeChar
          deriving Eq

instance Show Type where
  show TypeInt      = "int"
  show TypeBool     = "bool"
  show TypeBox      = "box"
  show TypeType     = "type"
  show TypeFunc     = "func"
  show TypeStr      = "str"
  show TypeChar     = "char"

anyType = undefined

(<:) :: Type -> Type -> Bool
(<:) = (==)
