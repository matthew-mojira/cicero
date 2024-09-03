module Type where

data Type = TypeInt
          | TypeBool
          deriving Eq

(<:) :: Type -> Type -> Bool
(<:) = (==)
