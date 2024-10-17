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
eval (ExprLit lit, _) = case lit of
  (LitInt int)   -> return $ ValInt int
  (LitBool bool) -> return $ ValBool bool
eval (ExprUnOp LNot expr@(_, posn), _) = do
  x <- eval expr
  case x of
    ValBool bool -> return $ ValBool $ not bool
    val -> do
      typ <- typeof val
      typeError TypeBool typ posn
eval (ExprBinOp op expr1@(_, pos1) expr2@(_, pos2), posn)
  | binOpEq op = do
    val1 <- eval expr1
    val2 <- eval expr2
    typ1 <- typeof val1
    typ2 <- typeof val2
    if typ1 == typ2
      then do
        let op' =
              case op of
                Eq  -> (==)
                Neq -> (/=)
        return $ ValBool $ op' val1 val2
      else typeError typ1 typ2 pos2
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
      (ValInt _, v2) -> do
        typ <- typeof v2
        typeError TypeInt typ pos2
      (v1, _)        -> do
        typ <- typeof v1
        typeError TypeInt typ pos1
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
      (ValInt _, v2) -> do
        typ <- typeof v2
        typeError TypeInt typ pos2
      (v1, _)        -> do
        typ <- typeof v1
        typeError TypeInt typ pos1
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
      (ValBool _, v2) -> do
        typ <- typeof v2
        typeError TypeBool typ pos2
      (v1, _)         -> do
        typ <- typeof v1
        typeError TypeBool typ pos1
eval (ExprIfElse pred@(_, posn) exprT exprF, _) = do
  x <- eval pred
  case x of
    ValBool bool -> do
      if bool
        then eval exprT
        else eval exprF
    val -> do
      typ <- typeof val
      typeError TypeBool typ posn
eval (ExprVar id expr, posn) = do
  env <- get
  case lookupEnv' id env of
  -- don't allow redeclaration in the same scope
    Just _  -> throwError $ Error posn (RedefinitionError id)
    Nothing -> do
      val <- eval expr
      env <- get
      put $ extendVar id val env
      return val
eval (ExprConst id expr, posn) = do
  env <- get
  case lookupEnv' id env of
  -- don't allow redeclaration in the same scope
    Just _  -> throwError $ Error posn (RedefinitionError id)
    Nothing -> do
      val <- eval expr
      env <- get
      put $ extendConst id val env
      return val
eval (ExprId id, posn) = do
  env <- get
  case lookupEnv id env of
    Just (val, _) -> return val
    Nothing       -> throwError $ Error posn (NameError id)
eval (ExprAssign id expr, posn) = do
  env <- get
  case lookupEnv id env of
    Just (_, True) -> do
      val <- eval expr
      env <- get
      put $ setVar id val env
      return val
    Just (_, False) -> throwError $ Error posn (AssignmentError id)
    Nothing -> throwError $ Error posn (NameError id)
eval (ExprUnOp Box expr@(_, posn), _) = do
  val <- eval expr
  env <- get
  let (env', idx) = boxValue val env
  put env'
  return $ ValBox idx
eval (ExprUnOp Unbox expr@(_, posn), _) = do
  val <- eval expr
  case val of
    ValBox _ -> do
      env <- get
      return $ unboxValue val env
    _ -> do
      typ <- typeof val
      typeError (TypeBox TypeAny) typ posn
eval (ExprSetBox exprD@(_, posn) exprS, _) = do
  valD <- eval exprD
  case valD of
    ValBox _ -> do
      valS <- eval exprS
      env  <- get
      put $ setBox valD valS env
      return valS
    _ -> do
      typ <- typeof valD
      typeError (TypeBox TypeAny) typ posn
-- first-class type stuff
eval (ExprUnOp Typeof expr, _) = do
  val <- eval expr
  typ <- typeof val
  return $ ValType typ
-- expression combinators
eval (ExprBlock exprs, _) = do
  modify pushBlock
  val <- foldM (const eval) ValVoid exprs
  modify popBlock
  return val
-- functions
eval (ExprFunc params expr, _) = do
  return $ ValFunc params expr
eval (ExprApply exprF@(_, posnF) exprsA, posn) = do
  valF <- eval exprF
  case valF of
    ValFunc params exprB -> do
      if length params == length exprsA
        then do
          args <- mapM eval exprsA
          modify $ pushFunc params args
          valR <- eval exprB
          modify $ popFunc

          return valR
        else do
          throwError $ Error posn (ArityMismatchError (length params) (length exprsA))
    _ -> do
      env <- get
      typ <- typeof valF
      typeError (TypeFunc (-1)) typ posnF

typeof :: Value -> Matthew Type
typeof (ValInt _)     = return TypeInt
typeof (ValBool _)    = return TypeBool
typeof box@(ValBox _) = do
  env <- get
  let val' = unboxValue box env
  typ <- typeof val'
  return $ TypeBox typ
typeof (ValType _)    = return TypeType
typeof ValVoid        = return TypeVoid
typeof (ValFunc ps _) = return $ TypeFunc (length ps)

typeError :: MonadError Error m => Type -> Type -> Posn -> m a
typeError exp act posn = throwError $ Error posn (TypeError exp act)
