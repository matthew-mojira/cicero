module Value (Value(..)) where

import AST
import Type

data Value = ValInt  Integer
           | ValBool Bool
           | ValBox  Int  -- pointer
           | ValType Type
           | ValFunc { params :: [String]
										 , env    :: [(String, Value)] -- closure
										 , body   :: ExprPosn          -- index into env
									   }
           | ValStr  String
           | ValChar Char
           deriving Eq

instance Show Value where
  show (ValInt int)    = show int
  show (ValBool bool)  = if bool then "true" else "false"
  show (ValBox idx)    = concat ["box[#", show idx, "]"]
  show (ValType typ)   = concat ["type[", show typ, "]"]
  show (ValFunc _ _ _) = concat ["func[<impl>]"]
  show (ValStr str)    = str
  show (ValChar char)  = show char
