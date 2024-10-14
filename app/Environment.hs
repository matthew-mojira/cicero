module Environment where

import Data.Maybe
import Data.List

import Value

data Env = Env { idxs :: [[[(String, (Value, Bool))]]]
                 -- three levels: func block list
               , vals :: [Value]
               }

emptyEnv :: Env
emptyEnv = Env [[]] []

popFunc :: Env -> Env
popFunc env@Env {idxs = idxs} = env {idxs = tail idxs} -- garbage collect?

pushFunc :: Env -> Env
pushFunc env@Env {idxs = idxs} = env {idxs = []:idxs}

popBlock :: Env -> Env
popBlock env@Env {idxs = idxs} = env {idxs = (tail (head idxs)):tail idxs}

pushBlock :: Env -> Env
pushBlock env@Env {idxs = idxs} = env {idxs = ([]:(head idxs)):tail idxs}

lookupEnv :: String -> Env -> Maybe (Value, Bool)
lookupEnv id (Env idxs _) = lookup id (concat (head idxs))

lookupEnv' :: String -> Env -> Maybe (Value, Bool)  -- strictly in the same scope
lookupEnv' id (Env idxs _) = lookup id (head (head idxs))

extendConst :: String -> Value -> Env -> Env
extendConst id val env@Env {idxs = idxs} =
  let Just (fun, funs) = uncons idxs
      Just (blk, blks) = uncons fun
   in env {idxs = (((id, (val, False)):blk):blks):funs}

extendVar :: String -> Value -> Env -> Env
extendVar id val env@Env {idxs = idxs} =
  let Just (fun, funs) = uncons idxs
      Just (blk, blks) = uncons fun
   in env {idxs = (((id, (val, True)):blk):blks):funs}

setVar :: String -> Value -> Env -> Env
setVar id val env@Env {idxs = idxs} =
  env {idxs = (replace id val (head idxs)):(tail idxs) }
  where
    replace :: Eq a => a -> b -> [[(a, (b, Bool))]] -> [[(a, (b, Bool))]]
    replace _ _ [] = []
    replace x y (dict:rest) = case replaceInDict dict of
        (newDict, True)  -> newDict : rest  -- Stop when the first replacement is made
        (newDict, False) -> newDict : replace x y rest
      where
        replaceInDict [] = ([], False)
        replaceInDict ((key, value@(_, bool)):xs)
          | key == x  = ((key, (y, bool)) : xs, True)
          | otherwise = let (restDict, replaced) = replaceInDict xs
                        in ((key, value) : restDict, replaced)
boxValue :: Value -> Env -> (Env, Value)
boxValue val env@Env {vals = vals} =
  let idx = length vals
   in (env {vals = val:vals}, ValBox idx)

unboxValue :: Value -> Env -> Value
unboxValue (ValBox idx) env@Env {vals = vals} = vals!!(length vals - idx - 1)

setBox :: Value -> Value -> Env -> Env
setBox (ValBox idx) val env@Env {vals = vals} =
  env {vals = setElem vals (length vals - idx - 1) val}
  where
    setElem :: [a] -> Int -> a -> [a]
    setElem xs i x = let (h, t:ts) = splitAt i xs
                      in h ++ x:ts

instance Show Env where
  show = undefined
--  show (Env idxs vals) = unlines $ map go idxs
--    where
--      go (id, (val, _)) = unwords [id, ":", show (typeof val), "=", show val]
