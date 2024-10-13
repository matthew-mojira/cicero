{-# LANGUAGE FlexibleContexts #-}

module Interpreter
  ( interp
  ) where

import Lexer (AlexPosn(AlexPn))

import Control.Monad
import Control.Monad.Except
import Control.Monad.Identity
import Control.Monad.Trans.Except
import Control.Monad.Trans.State

import AST
import Type
import Value

type Env = [(String, Value)]

type Error = String

type Matthew a = StateT Env (ExceptT Error IO) a

interp :: Prog -> IO (Either Error Value)
interp prog = runExceptT $ evalStateT (evalExpr prog) []

evalExpr :: ExprPosn -> Matthew Value
evalExpr ((ExprLit value), _) = return value
evalExpr ((ExprUnOp LNot expr), posn) = do
  x <- evalExpr expr
  case x of
    ValBool bool -> return $ ValBool $ not bool
    v            -> typeError TypeBool (typeof v) posn
evalExpr ((ExprBinOp op expr1@(_, pos1) expr2@(_, pos2)), posn)
  | binOpEq op = do
    val1 <- evalExpr expr1
    val2 <- evalExpr expr2
    let op' =
          case op of
            Eq -> (==)
            Neq -> (/=)
    return $ ValBool $ op' val1 val2
  | binOpComp op = do
    val1 <- evalExpr expr1
    val2 <- evalExpr expr2
    case (val1, val2) of
      (ValInt int1, ValInt int2) -> do
        let op' =
              case op of
                Le -> (<)
                Leq -> (<=)
                Ge -> (>)
                Geq -> (>=)
        return $ ValBool $ op' int1 int2
      (ValInt _, v2) -> typeError TypeInt (typeof v2) pos2
      (v1, ValInt _) -> typeError TypeInt (typeof v1) pos1
      (v1, _)        -> typeError TypeInt (typeof v1) pos1
  | binOpInt op = do
    val1 <- evalExpr expr1
    val2 <- evalExpr expr2
    let ValInt int1 = val1
    let ValInt int2 = val2
    let op' =
          case op of
            Add -> (+)
            Sub -> (-)
            Mult -> (*)
            Exp -> (^)
            Div -> div
    return $ ValInt $ op' int1 int2
  | binOpBool op = do
    val1 <- evalExpr expr1
    val2 <- evalExpr expr2
    let ValBool bool1 = val1
    let ValBool bool2 = val2
    let op' =
          case op of
            LAnd -> (&&)
            LOr -> (||)
    return $ ValBool $ op' bool1 bool2

typeError :: MonadError String m => Type -> Type -> Posn -> m a
typeError exp act (AlexPn _ line col, _) = throwError $ "type error at line " ++ show line ++ ", column " ++ show col ++ ": expected a value of type " ++ show exp ++ " but got type " ++ show act
