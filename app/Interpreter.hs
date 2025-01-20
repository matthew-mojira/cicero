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

import System.IO

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

returnBool :: Bool -> Matthew [Value]
returnBool = return . singleton . ValBool

returnInt :: Integer -> Matthew [Value]
returnInt = return . singleton . ValInt

returnVal :: Value -> Matthew [Value]
returnVal = return . singleton

eval :: ExprPosn -> Matthew [Value]
eval (ExprLit lit, _) = return $ singleton $ case lit of
  (LitInt int)   -> ValInt int
  (LitBool bool) -> ValBool bool
  (LitType typ)  -> ValType (interpType typ)
  (LitStr str)   -> ValStr str
  (LitChar char) -> ValChar char
eval (ExprUnOp Typeof expr@(_, posn), _) = do
  vals <- eval expr
  val  <- assertArity1 posn vals
  return [ValType (typeof val)]
eval (ExprUnOp LNot expr@(_, posn), _) = do
  bool <- eval expr >>= assertBool posn
  returnBool $ not bool
eval (ExprBinOp op expr1@(_, posn1) expr2@(_, posn2), posn)
  | binOpEq op = do
    val1 <- eval expr1 >>= assertArity1 posn1
    val2 <- eval expr2 >>= assertArity1 posn2
    assertType posn2 (typeof val1) val2
    let op' = case op of
                Eq  -> (==)
                Neq -> (/=)
    returnBool $ op' val1 val2
  | binOpComp op = do
    int1 <- eval expr1 >>= assertInt posn1
    int2 <- eval expr2 >>= assertInt posn2
    let op' = case op of
                Le  -> (<)
                Leq -> (<=)
                Ge  -> (>)
                Geq -> (>=)
    returnBool $ op' int1 int2
  | binOpInt op = do
    int1 <- eval expr1 >>= assertInt posn1
    int2 <- eval expr2 >>= assertInt posn2
    op' <- case op of
             Add  -> return (+)
             Sub  -> return (-)
             Mult -> return (*)
             Exp  -> return (^)
             Div  -> if int2 == 0
                       then throwError $ Error posn (ArithmeticError "division by zero")
                       else return div
    returnInt $ op' int1 int2
  | binOpBool op = do
    bool1 <- eval expr1 >>= assertBool posn1
    bool2 <- eval expr2 >>= assertBool posn2
    let op' = case op of
                LAnd -> (&&)
                LOr  -> (||)
    returnBool $ op' bool1 bool2
eval (ExprIfElse pred@(_, posn) exprT exprF, _) = do
  bool <- eval pred >>= assertBool posn
  if bool
    then eval exprT
    else eval exprF
eval (ExprVar id pat expr@(_, posnV), posn) = do
  assertNotDefined posn id

  val <- eval expr >>= assertArity1 posnV
  case pat of
    AnyP              -> modifyEnv $ extendVar id val pat
    TypeP typ Nothing -> do
      assertType posn (interpType typ) val
      modifyEnv $ extendVar id val pat
    TypeP typ (Just exprC) -> do
      assertType posn (interpType typ) val
      env <- getEnv
      res <- liftIO $ runStateT (runExceptT (eval exprC)) (extendVar id val pat env)
      -- three cases of errors
      -- - an error happened while evaluating the condition
      -- - the condition did not error, but the value is not a boolean
      -- - the value is a boolean, but it is false
      case res of
        (Left  err, _) -> throwError err -- an error happened when evaluating the condition
        (Right vals, env') -> do
          bool <- assertBool posn vals
          if bool
            then putEnv env' -- this includes the new binding anyway
            else throwError $ Error posn (AssertionError $ "failed condition on new variable " ++ id)
  returnVal val
eval (ExprId id, posn) = do
  env <- getEnv
  case lookupEnv id env of
    Just (val, _) -> returnVal val
    Nothing       -> throwError $ Error posn (NameError id)
eval (ExprAssign id expr@(_, posnV), posn) = do
  env <- getEnv
  case lookupEnv id env of
    Just (_, Nothing)  -> throwError $ Error posn (AssignmentError id)
    Just (_, Just pat) -> do
      val <- eval expr >>= assertArity1 posnV
      case pat of
        AnyP              -> modifyEnv $ setVar id val
        TypeP typ Nothing -> do
          assertType posn (interpType typ) val
          modifyEnv $ extendVar id val pat
        TypeP typ (Just exprC@(_, posnC)) -> do
          assertType posn (interpType typ) val
          env <- getEnv
          res <- liftIO $ runStateT (runExceptT (eval expr)) (setVar id val env)
          -- three cases of errors
          -- - an error happened while evaluating the condition
          -- - the condition did not error, but the value is not a boolean
          -- - the value is a boolean, but it is false
          case res of
            (Left  err, _) -> throwError err -- an error happened when evaluating the condition
            (Right vals, env') -> do
              bool <- assertBool posn vals
              if bool
                then putEnv env' -- this includes the new binding anyway
                else throwError $ Error posn (AssertionError $ "failed condition on modifying variable " ++ id)
      returnVal val
    Nothing -> throwError $ Error posn (NameError id)
eval (ExprBox typeE@(_, typeP) initE@(_, initP), _) = undefined
eval (ExprUnOp Unbox expr@(_, posn), _) = do
  idx <- eval expr >>= assertBox posn
  env <- getEnv
  returnVal $ unboxValue idx env
eval (ExprSetBox exprD@(_, posnD) exprS@(_, posnS), _) = undefined
-- expression combinators
eval (ExprBlock exprs, _) = do
  modifyEnv pushBlock
  val <- foldM (const eval) [] exprs
  modifyEnv popBlock
  return val -- TODO check this
-- iteration expressions
eval (ExprWhile exprG@(_, posnG) exprB, _) = do
  vals <- whileM evalGuard (eval exprB)
  case vals of
    [] -> return []
    _  -> return $ last vals -- TODO check this
  where
    evalGuard = eval exprG >>= assertBool posnG
eval (ExprTuple exprs, _) = mapM evalSingle exprs
  where
    evalSingle expr@(_, posn) = eval expr >>= assertArity1 posn
-- functions
eval (ExprFunc name params expr retPats, _) = do
  env <- getEnv
  case name of
    Nothing   -> return $ [ValFunc params (getClosure env) expr retPats]
    Just self -> do
      let func = ValFunc params ((self, func):(getClosure env)) expr retPats
      modifyEnv $ extendVar' self func
      return [func]
eval (ExprApply exprF@(_, posnF) exprsA@(_, posn), posnFIXME) = do
  -- assert we are calling a function
  valF <- eval exprF >>= assertFunc posnF
  let ValFunc params closure exprB retPats = valF

  -- assert correct number of args
  args <- eval exprsA
  assertArity (length params) args posn

  -- assert all patterns are satisfied
  env <- getEnv
  let env' = pushFunc (zip (map paramName params) (zip args (map paramPat params))) closure env
  env'' <- foldM checkArg env' (zip args params)

  -- call the function
  putEnv env''
  do
    valsR <- evalFunc exprB retPats
    modifyEnv popFunc
    return valsR
    -- error in evaluating function (including return type/arity)
    -- should be propagated up. this needs to be reorganized badly
    `catchError` (\err -> do
      modifyEnv popFunc
      throwError err)

  where
    -- function evaluation, refactor everything?
    evalFunc exprB retPats = do
      valsR <- eval exprB
      case retPats of
        Nothing   -> return ()
        Just pats -> do
          -- FIXME should be the location of the return value(s)
          assertArity (length pats) valsR posnFIXME
          -- at this point, we can only assert types are okay, can't check condition
          forM_ (zip valsR pats) $ \(val, pat) -> do
            case pat of
              AnyP        -> return ()
              TypeP typ _ -> assertType posnFIXME (interpType typ) val
      return valsR
    checkArg env (arg, Param name pat) = do
      case pat of
        AnyP              -> return env
        TypeP typ Nothing -> do
          assertType posn (interpType typ) arg
          return env
        TypeP typ (Just exprC@(_, posnC)) -> do
          assertType posn (interpType typ) arg
          res <- liftIO $ runStateT (runExceptT (eval exprC)) (setVar name arg env)
          -- three cases of errors
          -- - an error happened while evaluating the condition
          -- - the condition did not error, but the value is not a boolean
          -- - the value is a boolean, but it is false
          case res of
            (Left  err, _) -> throwError err -- an error happened when evaluating the condition
            (Right vals, env') -> do
              bool <- assertBool posn vals
              if bool
                then return env'
                else throwError $ Error posn (AssertionError $ "failed condition on argument " ++ name)
-- error
eval (ExprTry tryE catchE _, _) = catchError (eval tryE) (const $ eval catchE)
-- I/O
eval (ExprUnOp Print expr@(_, posn), _) = do
  val <- eval expr >>= assertArity1 posn
  liftIO $ print val
  liftIO $ hFlush stdout
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

{-
  ASSERTIONS
-}

assertType :: Posn -> Type -> Value -> Matthew ()
assertType posn typ val =
  if typeof val == typ
    then return ()
    else throwError $ Error posn (TypeError typ (typeof val))

assertArity :: Int -> [Value] -> Posn -> Matthew ()
assertArity cnt vals posn =
  if length vals == cnt
    then return ()
    else throwError $ Error posn (ArityMismatchError cnt (length vals))

assertArity1 :: Posn -> [Value] -> Matthew Value
assertArity1 posn vals = do
  assertArity 1 vals posn
  return $ head vals

{-
  Assert types
-}

assertBool :: Posn -> [Value] -> Matthew Bool
assertBool posn vals = do
  val <- assertArity1 posn vals
  assertType posn TypeBool val
  let ValBool bool = val
  return bool

assertInt :: Posn -> [Value] -> Matthew Integer
assertInt posn vals = do
  val <- assertArity1 posn vals
  assertType posn TypeInt val
  let ValInt int = val
  return int

assertBox :: Posn -> [Value] -> Matthew Int
assertBox _ [ValBox _ idx] = return idx
assertBox _ _ = undefined

assertFunc :: Posn -> [Value] -> Matthew Value
assertFunc posn vals = do
  val <- assertArity1 posn vals
  assertType posn TypeFunc val
  return val

-- don't allow redeclaration in the same scope
assertNotDefined :: Posn -> String -> Matthew ()
assertNotDefined posn id = do
  env <- getEnv
  case lookupEnv' id env of
    Just _  -> throwError $ Error posn (RedefinitionError id)
    Nothing -> return ()
