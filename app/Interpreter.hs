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

import Data.List
import Data.Maybe

import AST
import Type

import Environment

import Error
import Value

type Matthew a = StateT Env (ExceptT Error IO) a

interp :: Prog -> Env -> IO (Either Error ([Value], Env))
interp prog env = runExceptT $ runStateT (foldM (const eval) [] prog) env

eval :: ExprPosn -> Matthew [Value]
eval (ExprLit lit, _) = case lit of
  (LitInt int)   -> return [ValInt int]
  (LitBool bool) -> return [ValBool bool]
eval (ExprUnOp LNot expr@(_, posn), _) = do
  x <- eval expr
  case x of
    [ValBool bool] -> return $ [ValBool $ not bool]
    val            -> typeError [TypeBool] val posn
eval (ExprBinOp op expr1@(_, pos1) expr2@(_, pos2), posn)
  | binOpEq op = do
    val1 <- eval expr1
    val2 <- eval expr2
    typ1 <- mapM typeof val1
    typ2 <- mapM typeof val2
    if typ1 == typ2
      then do
        let op' =
              case op of
                Eq  -> (==)
                Neq -> (/=)
        return $ [ValBool $ op' val1 val2]
      else typeError typ1 val2 pos2
  | binOpComp op = do
    val1 <- eval expr1
    val2 <- eval expr2
    case (val1, val2) of
      ([ValInt int1], [ValInt int2]) -> do
        let op' =
              case op of
                Le  -> (<)
                Leq -> (<=)
                Ge  -> (>)
                Geq -> (>=)
        return $ [ValBool $ op' int1 int2]
      ([ValInt _], v2) -> typeError [TypeInt] v2 pos2
      (v1, _)          -> typeError [TypeInt] v1 pos1
  | binOpInt op = do
    val1 <- eval expr1
    val2 <- eval expr2
    case (val1, val2) of
      ([ValInt int1], [ValInt int2]) -> do
        op' <- case op of
          Add  -> return (+)
          Sub  -> return (-)
          Mult -> return (*)
          Exp  -> return (^)
          Div  -> if int2 == 0
                    then throwError $ Error posn (ArithmeticError "division by zero")
                    else return div
        return $ [ValInt $ op' int1 int2]
      ([ValInt _], v2) -> typeError [TypeInt] v2 pos2
      (v1, _)          -> typeError [TypeInt] v1 pos1
  | binOpBool op = do
    val1 <- eval expr1
    val2 <- eval expr2
    case (val1, val2) of
      ([ValBool bool1], [ValBool bool2]) -> do
        let op' =
                case op of
                  LAnd -> (&&)
                  LOr  -> (||)
        return $ [ValBool $ op' bool1 bool2]
      ([ValBool _], v2) -> typeError [TypeBool] v2 pos2
      (v1, _)           -> typeError [TypeBool] v1 pos1
eval (ExprIfElse pred@(_, posn) exprT exprF, _) = do
  x <- eval pred
  case x of
    [ValBool bool] -> do
      if bool
        then eval exprT
        else eval exprF
    val -> typeError [TypeBool] val posn
eval (ExprVar id pat expr@(_, posnV), posn) = do
  env <- get
  case lookupEnv' id env of
  -- don't allow redeclaration in the same scope
    Just _  -> throwError $ Error posn (RedefinitionError id)
    Nothing -> do
      vals <- eval expr
      case vals of
        [val] -> do
          assertMatch pat val posnV
          env <- get
          put $ extendVar id val env
          return [val]
        _ -> typeError [anyType] vals posnV
eval (ExprConst id pat expr@(_, posnV), posn) = do
  env <- get
  case lookupEnv' id env of
  -- don't allow redeclaration in the same scope
    Just _  -> throwError $ Error posn (RedefinitionError id)
    Nothing -> do
      vals <- eval expr
      case vals of
        [val] -> do
          assertMatch pat val posnV
          env <- get
          put $ extendConst id val env
          return [val]
        _ -> typeError [anyType] vals posnV
eval (ExprId id, posn) = do
  env <- get
  case lookupEnv id env of
    Just (val, _) -> return [val]
    Nothing       -> throwError $ Error posn (NameError id)
eval (ExprAssign id expr@(_, posnV), posn) = do
  env <- get
  case lookupEnv id env of
    Just (_, True) -> do
      vals <- eval expr
      case vals of
        [val] -> do
          env <- get
          put $ setVar id val env
          return [val]
        _ -> typeError [anyType] vals posnV
    Just (_, False) -> throwError $ Error posn (AssignmentError id)
    Nothing -> throwError $ Error posn (NameError id)
eval (ExprUnOp Box expr@(_, posn), _) = do
  vals <- eval expr
  case vals of
    [val] -> do
      env <- get
      let (env', idx) = boxValue val env
      put env'
      return $ [ValBox idx]
    _ -> typeError [anyType] vals posn
eval (ExprUnOp Unbox expr@(_, posn), _) = do
  val <- eval expr
  case val of
    [box@(ValBox _)] -> do
      env <- get
      return $ [unboxValue box env]
    _ -> typeError [TypeBox] val posn
eval (ExprSetBox exprD@(_, posnD) exprS@(_, posnS), _) = do
  valD <- eval exprD
  case valD of
    [box@(ValBox _)] -> do
      valS <- eval exprS
      case valS of
        [val] -> do
          env  <- get
          put $ setBox box val env
          return valS
        _ -> typeError [anyType] valS posnS
    _ -> typeError [TypeBox] valD posnD
-- expression combinators
eval (ExprBlock exprs, _) = do
  modify pushBlock
  val <- foldM (const eval) [] exprs
  modify popBlock
  return val
eval (ExprTuple exprs, _) = mapM evalSingle exprs
  where
    evalSingle expr@(_, posn) = do
      vals <- eval expr
      case vals of
        [val] -> return val
        _     -> typeError [undefined] vals posn
-- functions
eval (ExprFunc name params expr, _) = do
  env <- get
  case name of
    Nothing   -> return $ [ValFunc params (getClosure env) expr]
    Just self -> do
      let func = ValFunc params ((self, func):(getClosure env)) expr
      put $ extendConst self func env
      return [func]
eval (ExprApply exprF@(_, posnF) exprA@(_, posn), _) = do
  valF <- eval exprF
  case valF of
    [ValFunc params closure exprB] -> do
      args <- eval exprA
      if length params == length args
        then do
          modify $ pushFunc (zip params args) closure
          valR <- eval exprB
          modify $ popFunc

          return valR
        else typeError (replicate (length params) undefined) args posn
    _ -> typeError [TypeFunc] valF posnF


typeError :: [Type] -> [Value] -> Posn -> Matthew a
typeError exp val posn | length exp /= length val =
  throwError $ Error posn (ArityMismatchError (length exp) (length val))
typeError exps val posn | otherwise = do
  acts <- mapM typeof val
  let Just (exp, act) = find (\(t1, t2) -> t1 /= t2) (zip exps acts)
  throwError $ Error posn (TypeError exp act)

typeof :: Value -> Matthew Type
typeof (ValInt _)       = return TypeInt
typeof (ValBool _)      = return TypeBool
typeof (ValFunc ps _ _) = return TypeFunc
typeof (ValBox _)       = return TypeBox

assertMatch :: PatT -> Value -> Posn -> Matthew ()
assertMatch PatWild _ _             = return ()
assertMatch PatIntT (ValInt _) _    = return ()
assertMatch PatBoolT (ValBool _) _  = return ()
assertMatch PatFuncT (ValFunc {}) _ = return ()
assertMatch pat val posn            = undefined
--  typ <- typeof val
--  let typA = case lit of
--        IntT  -> TypeInt
--        BoolT -> TypeBool
--        FuncT -> TypeFunc
--        BoxT  -> TypeBox
--  if typ == typA
--    then return ()
--    else typeError [taypA] [val] posn
