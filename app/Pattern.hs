module Pattern where

data Pattern = PatInt
             | PatBool
             | PatBox  Pattern
             | PatFunc
             | PatAny
             | PatPat
             | PatErr
             | PatNone
             deriving Eq

instance Show Pattern where
  show PatInt       = "int"
  show PatBool      = "bool"
  show (PatBox pat) = concat ["box[", show pat, "]"]
  show PatFunc      = "func"
  show PatPat       = "type"
  show PatErr       = "error"
  show PatAny       = "any"

(<:) :: Pattern -> Pattern -> Bool
_           <: PatAny      = True
_           <: PatNone     = False
PatInt      <: PatInt      = True
PatBool     <: PatBool     = True
(PatBox b1) <: (PatBox b2) = b1 <: b2
PatFunc     <: PatFunc     = True
PatPat      <: PatPat      = True
PatErr      <: PatErr      = True
_           <: _           = False
