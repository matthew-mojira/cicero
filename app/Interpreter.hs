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

setVar :: String -> Value -> Matthew ()
setVar id val = do
  env <- get
  put $ rep env id (True, val)
  where
    rep :: Eq a => [(a, b)] -> a -> b -> [(a, b)]
    rep [] _ _ = []
    rep ((a, b):xs) x y
        | a == x    = (x, y) : xs
        | otherwise = (a, b) : rep xs x y

extendConst :: String -> Value -> Matthew ()
extendConst id val = do
  env <- get
  put $ (id, (False, val)):env

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
    if typeof val1 == typeof val2
      then do
        let op' =
              case op of
                Eq  -> (==)
                Neq -> (/=)
        return $ ValBool $ op' val1 val2
      else typeError (typeof val1) (typeof val2) pos2
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
  case lookup id env of
  -- don't allow redeclaration in the same scope
    Just _  -> throwError $ Error posn (RedefinitionError id)
    Nothing -> do
      val <- eval expr
      extendVar id val
      return val
eval (ExprConst id expr, posn) = do
  env <- get
  case lookup id env of
  -- don't allow redeclaration in the same scope
    Just _  -> throwError $ Error posn (RedefinitionError id)
    Nothing -> do
      val <- eval expr
      extendConst id val
      return val
eval (ExprId id, posn) = do
  env <- get
  case lookup id env of
    Just (_, v) -> return v
    Nothing     -> throwError $ Error posn (NameError id)
eval (ExprAssign id expr, posn) = do
  env <- get
  case lookup id env of
    Just (w, v) -> if w
      then do
        val <- eval expr
        setVar id val
        return val
      else throwError $ Error posn (AssignmentError id)
    Nothing -> throwError $ Error posn (NameError id)
-- first-class type stuff
eval (ExprUnOp Typeof expr, _) = do
  val <- eval expr
  return $ ValType $ typeof val

typeError :: MonadError Error m => Type -> Type -> Posn -> m a
typeError exp act posn = throwError $ Error posn (TypeError exp act)
