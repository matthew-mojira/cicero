module Type where

data Type = TypeInt
          | TypeBool
          | TypeVar
          | TypeAny
          deriving Eq

instance Show Type where
  show TypeInt     = "int"
  show TypeBool    = "bool"
  show TypeVar     = "var"
  show TypeAny     = "?"

(<:) :: Type -> Type -> Bool
(<:) = (==)
