module Value where

import AST
import Pattern

data Value = ValInt  Integer
           | ValBool Bool
           | ValBox  { pat   :: Pattern  -- not a value, just the internal pattern
                     , index :: Int
                     }
           | ValFunc { params  :: [Param]            -- constraint on values
                     , env     :: [(String, Value)]  -- closure
                     , body    :: ExprPosn           -- index into env
                     , retPats :: Maybe [Pattern]    -- return patterns/arity
                     }
           | ValPat  { pat :: Pattern }
           | ValStr  String
           | ValChar Char
           deriving Eq

typeof :: Value -> Pattern
typeof (ValInt _)     = PatInt
typeof (ValBool _)    = PatBool
typeof (ValBox pat _) = PatBox pat
typeof (ValFunc {})   = PatFunc
typeof (ValStr _)     = PatStr
typeof (ValChar _)    = PatChar
typeof (ValPat _)     = PatPat

matches :: Value -> Pattern -> Bool
matches val pat = (typeof val) <: pat

instance Show Value where
  show (ValInt int)    = show int
  show (ValBool bool)  = if bool then "true" else "false"
  show (ValBox _ idx)  = concat ["box[#", show idx, "]"]
  show (ValFunc _ _ _ _) = concat ["func[<impl>]"]
  show (ValPat pat)    = concat ["type[", show pat, "]"]
  show (ValStr str)    = show str
  show (ValChar char)  = show char
