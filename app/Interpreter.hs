{-# LANGUAGE FlexibleContexts #-}

module Interpreter
  ( interp, Env
  ) where

import Lexer (AlexPosn(AlexPn), Posn)

import Control.Monad
import Control.Monad.Except
import Control.Monad.Identity
import Control.Monad.Loops
import Control.Monad.IO.Class (liftIO)
import Control.Monad.Trans.Except
import Control.Monad.Trans.State

import Data.List
import Data.Maybe

import AST

import Environment

import Error
import Pattern
import Value

type Matthew a = ExceptT Error (StateT Env IO) a

getEnv :: Matthew Env
getEnv = lift get

putEnv :: Env -> Matthew ()
putEnv = lift . put

modifyEnv :: (Env -> Env) -> Matthew ()
modifyEnv = lift . modify

interp :: Prog -> Env -> IO (Either Error [Value], Env)
interp prog env = runStateT (runExceptT (foldM (const eval) [] prog)) env

eval :: ExprPosn -> Matthew [Value]
eval (ExprLit lit, _) = case lit of
  (LitInt int)   -> return [ValInt int]
  (LitBool bool) -> return [ValBool bool]
  (LitPat pat)   -> return [ValPat (interpPat pat)]
  (LitStr str)   -> return [ValStr str]
  (LitChar char) -> return [ValChar char]
eval (ExprUnOp Typeof expr@(_, posn), _) = do
  vals <- eval expr
  val  <- assertArity1 vals posn
  return [ValPat (typeof val)]
eval (ExprUnOp LNot expr@(_, posn), _) = do
  val <- eval expr
  assertTypes val [PatBool] posn
  let [ValBool bool] = val
  return [ValBool $ not bool]
eval (ExprBinOp op expr1@(_, posn1) expr2@(_, posn2), posn)
  | binOpEq op = do
    val1 <- eval expr1
    val2 <- eval expr2
    assertArity 1 val1 posn1 -- assert single arity
    let typ = typeof (val1!!0)
    assertTypes val2 [typ] posn2
    let op' = case op of
                Eq  -> (==)
                Neq -> (/=)
    return [ValBool $ op' val1 val2]
  | binOpComp op = do
    val1 <- eval expr1
    val2 <- eval expr2
    assertTypes val1 [PatInt] posn1
    assertTypes val2 [PatInt] posn2
    let [ValInt int1] = val1
    let [ValInt int2] = val2
    let op' = case op of
                Le  -> (<)
                Leq -> (<=)
                Ge  -> (>)
                Geq -> (>=)
    return [ValBool $ op' int1 int2]
  | binOpInt op = do
    val1 <- eval expr1
    val2 <- eval expr2
    assertTypes val1 [PatInt] posn1
    assertTypes val2 [PatInt] posn2
    let [ValInt int1] = val1
    let [ValInt int2] = val2
    op' <- case op of
             Add  -> return (+)
             Sub  -> return (-)
             Mult -> return (*)
             Exp  -> return (^)
             Div  -> if int2 == 0
                       then throwError $ Error posn (ArithmeticError "division by zero")
                       else return div
    return [ValInt $ op' int1 int2]
  | binOpBool op = do
    val1 <- eval expr1
    val2 <- eval expr2
    assertTypes val1 [PatBool] posn1
    assertTypes val2 [PatBool] posn2
    let [ValBool bool1] = val1
    let [ValBool bool2] = val2
    let op' = case op of
                LAnd -> (&&)
                LOr  -> (||)
    return [ValBool $ op' bool1 bool2]
eval (ExprIfElse pred@(_, posn) exprT exprF, _) = do
  val <- eval pred
  assertTypes val [PatBool] posn
  let [ValBool bool] = val
  if bool
    then eval exprT
    else eval exprF
eval (ExprVar id pat expr@(_, posnV), posn) = do
  env <- getEnv
  case lookupEnv' id env of
  -- don't allow redeclaration in the same scope
    Just _  -> throwError $ Error posn (RedefinitionError id)
    Nothing -> do
      vals <- eval expr
      assertArity 1 vals posnV
      let [val] = vals
      let pat' = interpPat pat
      assertType val pat' posnV
      modifyEnv $ extendVar id val pat'
      return [val]
eval (ExprConst id pat expr@(_, posnV), posn) = do
  env <- getEnv
  case lookupEnv' id env of
  -- don't allow redeclaration in the same scope
    Just _  -> throwError $ Error posn (RedefinitionError id)
    Nothing -> do
      vals <- eval expr
      assertArity 1 vals posnV
      let [val] = vals
      let pat' = interpPat pat
      assertType val pat' posnV
      modifyEnv $ extendConst id val
      return [val]
eval (ExprId id, posn) = do
  env <- getEnv
  case lookupEnv id env of
    Just (val, _) -> return [val]
    Nothing       -> throwError $ Error posn (NameError id)
eval (ExprAssign id expr@(_, posnV), posn) = do
  env <- getEnv
  case lookupEnv id env of
    Just (_, pat) -> do
      vals <- eval expr
      assertArity 1 vals posnV
      let [val] = vals
      when (pat == PatNone) $ throwError $ Error posn (AssignmentError id)
      assertType val pat posnV
      modifyEnv $ setVar id val
      return [val]
    Nothing -> throwError $ Error posn (NameError id)
eval (ExprBox patE@(_, patP) initE@(_, initP), _) = do  -- new naming convention
  patV <- eval patE
  assertTypes patV [PatPat] patP
  let [ValPat pat] = patV
  initV <- eval initE
  assertTypes initV [pat] initP  -- assert both arity and type
  let [val] = initV
  env <- getEnv
  let (env', idx) = boxValue val env
  putEnv env'
  return [ValBox pat idx]
eval (ExprUnOp Unbox expr@(_, posn), _) = do
  val <- eval expr
  assertTypes val [PatBox PatAny] posn
  let [ValBox _ idx] = val
  env <- getEnv
  return [unboxValue idx env]
eval (ExprSetBox exprD@(_, posnD) exprS@(_, posnS), _) = do
  valD <- eval exprD
  assertTypes valD [PatBox PatAny] posnD
  let [(ValBox pat idx)] = valD
  valS <- eval exprS
  assertTypes valS [pat] posnS
  modifyEnv $ setBox idx (valS!!0)
  return valS
-- expression combinators
eval (ExprBlock exprs, _) = do
  modifyEnv pushBlock
  val <- foldM (const eval) [] exprs
  modifyEnv popBlock
  return val
-- iteration expressions
eval (ExprWhile exprG@(_, posnG) exprB, _) = do
  vals <- whileM evalGuard (eval exprB)
  case vals of
    [] -> return []
    _  -> return $ last vals
  where
    evalGuard = do
      valG <- eval exprG
      assertTypes valG [PatBool] posnG
      let [ValBool bool] = valG
      return bool
eval (ExprTuple exprs, _) = mapM evalSingle exprs
  where
    evalSingle expr@(_, posn) = do
      vals <- eval expr
      assertArity 1 vals posn
      let [val] = vals
      return val
-- functions
eval (ExprFunc name params expr retPats, _) = do
  env <- getEnv
  case name of
    Nothing   -> return $ [ValFunc params (getClosure env) expr (fmap (map interpPat) retPats)]
    Just self -> do
      let func = ValFunc params ((self, func):(getClosure env)) expr (fmap (map interpPat) retPats)
      modifyEnv $ extendConst self func
      return [func]
eval (ExprApply exprF@(_, posnF) exprsA@(_, posn), posnFIXME) = do
  -- assert we are calling a function
  valF <- eval exprF
  assertTypes valF [PatFunc] posnF
  let [ValFunc params closure exprB retPats] = valF
  -- assert that params are the correct type
  args <- eval exprsA
  assertTypes args (map interpParam params) posn
  -- call the function
  modifyEnv $ pushFunc (zip (map paramName params) args) closure

  -- this should be abstracted better (abstract the entire function eval)
  do
    valR <- evalFunc exprB retPats
    modifyEnv popFunc
    return valR
    `catchError` (\err -> do
      modifyEnv popFunc
      throwError err)

  where
    interpParam = interpPat . paramPat
-- I/O
eval (ExprUnOp Print expr@(_, posn), _) = do
  x <- eval expr
  val <- assertArity1 x posn
  liftIO $ print val
  return []
eval (ExprZeroOp Scan, _) = do
  str <- liftIO $ getLine
  return [ValStr str]

    evalFunc exprB retPats = do
      valR <- eval exprB
      -- assert return value is correct type
      -- note: this is really not the place to do it. it needs to be in the function
      case retPats of
        Nothing   -> return ()
        Just pats -> assertTypes valR pats posnFIXME
      return valR

-- error
eval (ExprTry tryE catchE _, _) = catchError (eval tryE) (const $ eval catchE)


interpPat :: PatT -> Pattern
interpPat PatIntT       = PatInt
interpPat PatBoolT      = PatBool
interpPat (PatBoxT pat) = PatBox (interpPat pat)
interpPat PatFuncT      = PatFunc
interpPat PatStrT       = PatStr
interpPat PatCharT      = PatChar
interpPat PatWild       = PatAny

assertType :: Value -> Pattern -> Posn -> Matthew ()
assertType val pat posn =
  if val `matches` pat
    then return ()
    else throwError $ Error posn (TypeError pat (typeof val))

assertTypes :: [Value] -> [Pattern] -> Posn -> Matthew ()
assertTypes vals pats posn =
  if length vals /= length pats
    then throwError $ Error posn (ArityMismatchError (length pats) (length vals))
    else mapM_ (\(val, pat) -> assertType val pat posn) (zip vals pats)

assertArity :: Int -> [Value] -> Posn -> Matthew ()
assertArity cnt vals posn = assertTypes vals (replicate cnt PatAny) posn

assertArity1 :: [Value] -> Posn -> Matthew Value
assertArity1 vals posn = do
  assertArity 1 vals posn
  return $ head vals
