module Pattern where

data Pattern = PatInt
             | PatBool
             | PatBox  Pattern
             | PatFunc
             | PatAny
             | PatNone
             deriving (Eq, Show)

(<:) :: Pattern -> Pattern -> Bool
_           <: PatAny      = True
_           <: PatNone     = False
PatInt      <: PatInt      = True
PatBool     <: PatBool     = True
(PatBox b1) <: (PatBox b2) = b1 <: b2
PatFunc     <: PatFunc     = True
_           <: _           = False
