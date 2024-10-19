module Type where

data Type = TypeInt
          | TypeBool
          | TypeBox
          | TypeType
          | TypeFunc
          deriving Eq

instance Show Type where
  show TypeInt      = "int"
  show TypeBool     = "bool"
  show TypeBox      = "box"
  show TypeType     = "type"
  show TypeFunc     = "func"

anyType = undefined

(<:) :: Type -> Type -> Bool
(<:) = (==)
