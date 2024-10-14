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

import Data.Maybe

import AST
import Type

import Environment

import Error
import Value

type Matthew a = StateT Env (ExceptT Error IO) a

interp :: Prog -> Env -> IO (Either Error (Value, Env))
interp prog env = runExceptT $ runStateT (eval prog) env

eval :: ExprPosn -> Matthew Value
eval (ExprLit value, _) = return value
eval (ExprUnOp LNot expr@(_, posn), _) = do
  x <- eval expr
  case x of
    ValBool bool -> return $ ValBool $ not bool
    v            -> typeError TypeBool (typeof v) posn
eval (ExprBinOp op expr1@(_, pos1) expr2@(_, pos2), posn)
  | binOpEq op = do
    val1 <- eval expr1
    val2 <- eval expr2
    let op' =
          case op of
            Eq  -> (==)
            Neq -> (/=)
    return $ ValBool $ op' val1 val2
  | binOpComp op = do
    val1 <- eval expr1
    val2 <- eval expr2
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
    val1 <- eval expr1
    val2 <- eval expr2
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
    val1 <- eval expr1
    val2 <- eval expr2
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
eval (ExprIfElse pred@(_, posn) exprT exprF, _) = do
  x <- eval pred
  case x of
    ValBool bool -> do
      if bool
        then eval exprT
        else eval exprF
    v            -> typeError TypeBool (typeof v) posn
eval (ExprVar id expr, posn) = do
  env <- get
  case lookupEnv id env of
  -- don't allow redeclaration in the same scope
    Just _  -> throwError $ Error posn (RedefinitionError id)
    Nothing -> do
      val <- eval expr
      let (env', val') = extendVar id val env
      put env'
      return val'
eval (ExprConst id expr, posn) = do
  env <- get
  case lookupEnv id env of
  -- don't allow redeclaration in the same scope
    Just _  -> throwError $ Error posn (RedefinitionError id)
    Nothing -> do
      val <- eval expr
      put $ extendConst id val env
      return val
eval (ExprId id, posn) = do
  env <- get
  case lookupEnv id env of
    Just v  -> return v
    Nothing -> throwError $ Error posn (NameError id)
eval (ExprAssign exprL@(_, posnL) exprR, posn) = do
  valL <- eval exprL
  case valL of
    ValVar idx -> do
      env <- get
      val <- eval exprR
      put $ setFromIdx idx val env
      return val
    val -> typeError TypeVar (typeof val) posnL
eval (ExprUnOp Deref expr@(_, posn), _) = do
  x <- eval expr
  case x of
    ValVar idx -> do
      env <- get
      return $ fromJust $ lookupIdx idx env
    v -> typeError TypeVar (typeof v) posn

typeError :: MonadError Error m => Type -> Type -> Posn -> m a
typeError exp act posn = throwError $ Error posn (TypeError exp act)
