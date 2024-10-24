module Value where

import AST
import Pattern

data Value = ValInt  Integer
           | ValBool Bool
           | ValBox  Pat Int  -- pointer
           | ValFunc { params :: [String]
										 , env    :: [(String, Value)] -- closure
										 , body   :: ExprPosn          -- index into env
									   }
           deriving Eq

typeof :: Value -> Pattern
typeof (ValInt _)     = PatInt
typeof (ValBool _)    = PatBool
typeof (ValBox pat _) = PatBox pat
typeof (ValFunc {})   = PatFunc

matches :: Value -> Pat -> Bool
matches val pat = let pat' = Just (typeof val)
                   in pat' <: pat

instance Show Value where
  show (ValInt int)    = show int
  show (ValBool bool)  = if bool then "true" else "false"
  show (ValBox _ idx)  = concat ["box[#", show idx, "]"]
  show (ValFunc _ _ _) = concat ["func[<impl>]"]
