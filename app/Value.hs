module Value where

import AST
import Error
import Type

data Value = ValInt  Integer
           | ValBool Bool
           | ValBox  { typ   :: Type
                     , index :: Int
                     }
           | ValFunc { params  :: [Param]            -- constraint on values
                     , env     :: [(String, Value)]  -- closure
                     , body    :: ExprPosn           -- index into env
                     , retPats :: Maybe [Pattern]    -- return patterns/arity
                     }
           | ValType { typ :: Type }
           | ValErr  { err :: Error }
           | ValStr  String
           | ValChar Char
           deriving Eq

typeof :: Value -> Type
typeof (ValInt _)     = TypeInt
typeof (ValBool _)    = TypeBool
typeof (ValBox pat _) = TypeBox pat
typeof (ValFunc {})   = TypeFunc
typeof (ValStr _)     = TypeStr
typeof (ValChar _)    = TypeChar
typeof (ValType _)    = TypeType
typeof (ValErr _)     = TypeErr

instance Show Value where
  show (ValInt int)    = show int
  show (ValBool bool)  = if bool then "true" else "false"
  show (ValBox _ idx)  = concat ["box[#", show idx, "]"]
  show (ValFunc _ _ _ _) = concat ["func[<impl>]"]
  show (ValType typ)    = concat ["type[", show typ, "]"]
  show (ValErr _)      = concat ["error[?]"]
  show (ValStr str)    = show str
  show (ValChar char)  = show char
