module Type where

data Type = TypeInt
          | TypeBool
          | TypeBox
          | TypeFunc
          deriving Eq

instance Show Type where
  show TypeInt      = "int"
  show TypeBool     = "bool"
  show TypeBox      = "box"
  show TypeFunc     = "func"

anyType = undefined

(<:) :: Type -> Type -> Bool
(<:) = (==)
