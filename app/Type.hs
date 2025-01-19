module Type where

data Type = TypeInt
          | TypeBool
          | TypeBox Type
          | TypeFunc
          | TypeStr
          | TypeChar
          | TypeType
          | TypeErr
          deriving Eq

instance Show Type where
  show TypeInt       = "int"
  show TypeBool      = "bool"
  show (TypeBox typ) = concat ["box[", show typ, "]"]
  show TypeFunc      = "func"
  show TypeStr       = "str"
  show TypeChar      = "char"
  show TypeType      = "type"
  show TypeErr       = "error"

(<:) :: Type -> Type -> Bool
TypeInt      <: TypeInt      = True
TypeBool     <: TypeBool     = True
(TypeBox b1) <: (TypeBox b2) = b1 <: b2
TypeFunc     <: TypeFunc     = True
TypeChar     <: TypeChar     = True
TypeType     <: TypeType     = True
TypeErr      <: TypeErr      = True
_            <: _            = False
