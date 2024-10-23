module Value (Value(..)) where

import AST

data Value = ValInt  Integer
           | ValBool Bool
           | ValBox  Int  -- pointer
           | ValFunc { params :: [String]
										 , env    :: [(String, Value)] -- closure
										 , body   :: ExprPosn          -- index into env
									   }
           deriving Eq

instance Show Value where
  show (ValInt int)   = show int
  show (ValBool bool) = if bool then "true" else "false"
  show (ValBox idx)   = concat ["box[#", show idx, "]"]
  show (ValFunc _ _ _) = concat ["func[<impl>]"]
