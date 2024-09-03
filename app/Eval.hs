module Eval where

import AST
import Value

-- type Prog = Expr
eval :: Prog -> Value
eval prog = evalExpr prog

evalExpr :: Expr -> Value
evalExpr (ExprLit value) = value
evalExpr (ExprBinOp op expr1 expr2) = let ValInt val1 = evalExpr expr1
                                          ValInt val2 = evalExpr expr2
                                          op' = case op of
                                                  Add  -> (+)
                                                  Sub  -> (-)
                                                  Mult -> (*)
                                                  Div  -> div
                                       in ValInt $ op' val1 val2
