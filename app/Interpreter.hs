{-# LANGUAGE FlexibleContexts #-}

module Interpreter
  ( interp, Env
  ) where

import Lexer (AlexPosn(AlexPn), Posn)

import Control.Monad
import Control.Monad.Except
import Control.Monad.Identity
import Control.Monad.Trans.Except
import Control.Monad.Trans.State

import AST
import Type

import Error
import Value

type Env = [(String, (Bool, Value))]

extendVar :: String -> Value -> Matthew ()
extendVar id val = do
  env <- get
  put $ (id, (True, val)):env

extendConst :: String -> Value -> Matthew ()
extendConst id val = do
  env <- get
  put $ (id, (False, val)):env

type Matthew a = StateT Env (ExceptT Error IO) a

interp :: Prog -> Env -> IO (Either Error (Value, Env))
interp prog env = runExceptT $ runStateT (evalExpr prog) env

evalExpr :: ExprPosn -> Matthew Value
evalExpr (ExprLit value, _) = return value
evalExpr (ExprUnOp LNot expr@(_, posn), _) = do
  x <- evalExpr expr
  case x of
    ValBool bool -> return $ ValBool $ not bool
    v            -> typeError TypeBool (typeof v) posn
evalExpr (ExprBinOp op expr1@(_, pos1) expr2@(_, pos2), posn)
  | binOpEq op = do
    val1 <- evalExpr expr1
    val2 <- evalExpr expr2
    let op' =
          case op of
            Eq  -> (==)
            Neq -> (/=)
    return $ ValBool $ op' val1 val2
  | binOpComp op = do
    val1 <- evalExpr expr1
    val2 <- evalExpr expr2
    case (val1, val2) of
      (ValInt int1, ValInt int2) -> do
        let op' =
              case op of
                Le  -> (<)
                Leq -> (<=)
                Ge  -> (>)
                Geq -> (>=)
        return $ ValBool $ op' int1 int2
      (ValInt _, v2) -> typeError TypeInt (typeof v2) pos2
      (v1, ValInt _) -> typeError TypeInt (typeof v1) pos1
      (v1, _)        -> typeError TypeInt (typeof v1) pos1
  | binOpInt op = do
    val1 <- evalExpr expr1
    val2 <- evalExpr expr2
    case (val1, val2) of
      (ValInt int1, ValInt int2) -> do
        op' <- case op of
          Add  -> return (+)
          Sub  -> return (-)
          Mult -> return (*)
          Exp  -> return (^)
          Div  -> if int2 == 0
                    then throwError $ Error posn (ArithmeticError "division by zero")
                    else return div
        return $ ValInt $ op' int1 int2
      (ValInt _, v2) -> typeError TypeInt (typeof v2) pos2
      (v1, ValInt _) -> typeError TypeInt (typeof v1) pos1
      (v1, _)        -> typeError TypeInt (typeof v1) pos1
  | binOpBool op = do
    val1 <- evalExpr expr1
    val2 <- evalExpr expr2
    case (val1, val2) of
      (ValBool bool1, ValBool bool2) -> do
        let op' =
                case op of
                  LAnd -> (&&)
                  LOr  -> (||)
        return $ ValBool $ op' bool1 bool2
      (ValBool _, v2) -> typeError TypeBool (typeof v2) pos2
      (v1, ValBool _) -> typeError TypeBool (typeof v1) pos1
      (v1, _)         -> typeError TypeBool (typeof v1) pos1
evalExpr (ExprIfElse pred@(_, posn) exprT exprF, _) = do
  x <- evalExpr pred
  case x of
    ValBool bool -> do
      if bool
        then evalExpr exprT
        else evalExpr exprF
    v            -> typeError TypeBool (typeof v) posn
evalExpr (ExprVar id expr, posn) = do
  env <- get
  case lookup id env of
  -- don't allow redeclaration in the same scope
    Just _  -> throwError $ Error posn (RedefinitionError id)
    Nothing -> do
      val <- evalExpr expr
      extendVar id val
      return val
evalExpr (ExprConst id expr, posn) = do
  env <- get
  case lookup id env of
  -- don't allow redeclaration in the same scope
    Just _  -> throwError $ Error posn (RedefinitionError id)
    Nothing -> do
      val <- evalExpr expr
      extendConst id val
      return val
evalExpr (ExprId id, posn) = do
  env <- get
  case lookup id env of
    Just (_, v) -> return v
    Nothing     -> throwError $ Error posn (NameError id)

typeError :: MonadError Error m => Type -> Type -> Posn -> m a
typeError exp act posn = throwError $ Error posn (TypeError exp act)
