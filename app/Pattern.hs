module Pattern where

type Pat = Maybe Pattern

data Pattern = PatInt
             | PatBool
             | PatBox Pat
             | PatFunc
             deriving (Eq, Show)

(<:) :: Pat -> Pat -> Bool
_                  <: Nothing            = True
Nothing            <: Nothing            = True
(Just PatInt)      <: (Just PatInt)      = True
(Just PatBool)     <: (Just PatBool)     = True
(Just (PatBox b1)) <: (Just (PatBox b2)) = b1 <: b2
(Just PatFunc)     <: (Just PatFunc)     = True
_                  <: _                  = False
