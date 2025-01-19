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
import Type
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
  (LitType typ)  -> return [ValType (interpType typ)]
  (LitStr str)   -> return [ValStr str]
  (LitChar char) -> return [ValChar char]
eval (ExprUnOp Typeof expr@(_, posn), _) = do
  vals <- eval expr
  val  <- assertArity1 vals posn
  return [ValType (typeof val)]
eval (ExprUnOp LNot expr@(_, posn), _) = do
  val <- eval expr
  assertTypes val [TypeBool] posn
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
    assertTypes val1 [TypeInt] posn1
    assertTypes val2 [TypeInt] posn2
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
    assertTypes val1 [TypeInt] posn1
    assertTypes val2 [TypeInt] posn2
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
    assertTypes val1 [TypeBool] posn1
    assertTypes val2 [TypeBool] posn2
    let [ValBool bool1] = val1
    let [ValBool bool2] = val2
    let op' = case op of
                LAnd -> (&&)
                LOr  -> (||)
    return [ValBool $ op' bool1 bool2]
eval (ExprIfElse pred@(_, posn) exprT exprF, _) = do
  val <- eval pred
  assertTypes val [TypeBool] posn
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
      assertPat id val posnV pat
      modifyEnv $ extendVar id val pat
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
      assertPat id val posnV pat
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
      when (pat == NoneP) $ throwError $ Error posn (AssignmentError id)
      -- TODO modification is observable
      assertPat' id val posnV pat
      modifyEnv $ setVar id val
      return [val]
    Nothing -> throwError $ Error posn (NameError id)
eval (ExprBox typeE@(_, typeP) initE@(_, initP), _) = do  -- new naming convention
  typeV <- eval typeE
  assertTypes typeV [TypeType] typeP
  let [ValType typ] = typeV
  initV <- eval initE
  assertTypes initV [typ] initP  -- assert both arity and type
  let [val] = initV
  env <- getEnv
  let (env', idx) = boxValue val env
  putEnv env'
  return [ValBox typ idx]
eval (ExprUnOp Unbox expr@(_, posn), _) = do
  vals <- eval expr
  val <- assertArity1 vals posn
  assertBox val posn
  let ValBox _ idx = val
  env <- getEnv
  return [unboxValue idx env]
eval (ExprSetBox exprD@(_, posnD) exprS@(_, posnS), _) = do
  vals <- eval exprD
  valD <- assertArity1 vals posnD
  assertBox valD posnD
  let ValBox typ idx = valD
  valS <- eval exprS
  assertTypes valS [typ] posnS
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
      assertTypes valG [TypeBool] posnG
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
    Nothing   -> return $ [ValFunc params (getClosure env) expr retPats]
    Just self -> do
      let func = ValFunc params ((self, func):(getClosure env)) expr retPats
      modifyEnv $ extendConst self func
      return [func]
eval (ExprApply exprF@(_, posnF) exprsA@(_, posn), posnFIXME) = do
  -- assert we are calling a function
  valF <- eval exprF
  assertTypes valF [TypeFunc] posnF
  let [ValFunc params closure exprB retPats] = valF

  -- assert correct number of args
  args <- eval exprsA
  assertArity (length params) args posn

  -- assert that args are the correct type
  -- TODO observable
  modifyEnv $ pushFunc (zip (map paramName params) args) closure
  forM_ (zip args params) $ \(arg, Param name pat) -> do
    case pat of
      AnyP -> return ()
      TypeP typ con -> do
        assertType arg (interpType typ) posnFIXME
        case con of
          Nothing -> return ()
          Just exprC@(_, posnC) -> do
            -- assert the condition
            valC <- eval exprC
            assertTypes valC [TypeBool] posnC
            let [ValBool bool] = valC
            if bool
              then return ()
              else throwError $ Error posnC (AssertionError $ "failed check on parameter " ++ name)
  -- call the function
  -- this should be abstracted better (abstract the entire function eval)
  do
    valR <- evalFunc exprB retPats
    modifyEnv popFunc
    return valR
    `catchError` (\err -> do
      modifyEnv popFunc
      throwError err)

  where
    evalFunc exprB retPats = do
      valR <- eval exprB
      -- assert return value is correct type
      -- note: this is really not the place to do it. it needs to be in the function
      -- TODO reimplement this
--      case retPats of
--        Nothing   -> return ()
--        Just pats -> assertTypes valR types posnFIXME
      return valR
-- error
eval (ExprTry tryE catchE _, _) = catchError (eval tryE) (const $ eval catchE)
-- I/O
eval (ExprUnOp Print expr@(_, posn), _) = do
  x <- eval expr
  val <- assertArity1 x posn
  liftIO $ print val
  return []
eval (ExprZeroOp Scan, _) = do
  str <- liftIO $ getLine
  return [ValStr str]

interpType :: LitT -> Type
interpType IntT       = TypeInt
interpType BoolT      = TypeBool
interpType (BoxT typ) = TypeBox (interpType typ)
interpType FuncT      = TypeFunc
interpType StrT       = TypeStr
interpType CharT      = TypeChar

assertType :: Value -> Type -> Posn -> Matthew ()
assertType val typ posn =
  if typeof val == typ
    then return ()
    else throwError $ Error posn (TypeError typ (typeof val))

assertTypes :: [Value] -> [Type] -> Posn -> Matthew ()
assertTypes vals types posn =
  if length vals /= length types
    then throwError $ Error posn (ArityMismatchError (length types) (length vals))
    else mapM_ (\(val, typ) -> assertType val typ posn) (zip vals types)

assertArity :: Int -> [Value] -> Posn -> Matthew ()
assertArity cnt vals posn =
  if length vals == cnt
    then return ()
    else throwError $ Error posn (ArityMismatchError cnt (length vals))

assertArity1 :: [Value] -> Posn -> Matthew Value
assertArity1 vals posn = do
  assertArity 1 vals posn
  return $ head vals

assertBox :: Value -> Posn -> Matthew ()
assertBox (ValBox _ _) _ = return ()
assertBox val posn       = throwError $ Error posn (TypeError (TypeBox undefined) (typeof val))

-- assert that a new binding is valid (both in type and condition)
assertPat :: String -> Value -> Posn -> Pattern -> Matthew ()
assertPat _ _ _ AnyP                         = return ()
assertPat _ _ _ NoneP                        = return () -- add failure here
assertPat _ val posn (TypeP typ Nothing)     = do
  assertType val (interpType typ) posn
assertPat id val posnV pat@(TypeP typ (Just expr@(_, posn))) = do
  assertType val (interpType typ) posnV -- refactor everything
  env <- getEnv
  let env' = extendVar id val pat env
  res <- liftIO $ runStateT (runExceptT (eval expr)) env'
  case res of
    (Left  err, _)     -> throwError err
    (Right vals, env'') -> do
      val <- assertArity1 vals posn
      assertType val TypeBool posn
      let ValBool bool = val
      if bool
        then putEnv env''
        else throwError $ Error posn (AssertionError "failed condition on new binding")

-- assert that modifying an existing binding is valid (both in type and condition)
assertPat' :: String -> Value -> Posn -> Pattern -> Matthew ()
assertPat' _ _ _ AnyP                         = return ()
assertPat' _ _ _ NoneP                        = return () -- add failure here
assertPat' _ val posn (TypeP typ Nothing)     = do
  assertType val (interpType typ) posn
assertPat' id val posnV pat@(TypeP typ (Just expr@(_, posn))) = do
  assertType val (interpType typ) posnV -- refactor everything
  env <- getEnv
  let env' = setVar id val env
  res <- liftIO $ runStateT (runExceptT (eval expr)) env'
  case res of
    (Left  err, _)     -> throwError err
    (Right vals, env'') -> do
      val <- assertArity1 vals posn
      assertType val TypeBool posn
      let ValBool bool = val
      if bool
        then putEnv env''
        else throwError $ Error posn (AssertionError "failed condition on modifying existing binding")

