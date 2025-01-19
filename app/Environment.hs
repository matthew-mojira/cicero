module Environment where

import Data.Maybe
import Data.List

import Value
import AST

type Entry      = (String, (Value, Pattern))
type BlockEntry = [Entry]
type FuncEntry  = [BlockEntry]

data Env = Env { idxs :: [FuncEntry]
                 -- three levels: func block list
                 -- [ func1, func2, func3, ..., funcN ]
                 --    ^
                 --    \-- [ block1, block2, block3, ..., blockN ]
                 --          ^
                 --          \-- [ bind1, bind2, bind3, ..., bindN ]
               , vals :: [Value]
               }
         deriving Show

emptyEnv :: Env
emptyEnv = Env [[[]]] []

popFunc :: Env -> Env
popFunc env@Env {idxs = idxs} = env {idxs = tail idxs} -- garbage collect?

pushFunc :: [(String, Value)] -> [(String, Value)] -> Env -> Env
pushFunc args closure env@Env {idxs = idxs} =
  env {idxs = [map (\(id, val) -> (id, (val, NoneP))) (args ++ closure)]:idxs}

popBlock :: Env -> Env
popBlock env@Env {idxs = idxs} = env {idxs = (tail (head idxs)):tail idxs}

pushBlock :: Env -> Env
pushBlock env@Env {idxs = idxs} = env {idxs = ([]:(head idxs)):tail idxs}

lookupEnv :: String -> Env -> Maybe (Value, Pattern)
lookupEnv id (Env {idxs = idxs}) = lookup id (concat (head idxs))

lookupEnv' :: String -> Env -> Maybe (Value, Pattern)  -- strictly in the same scope
lookupEnv' id (Env {idxs = idxs}) = lookup id (head (head idxs))

extendConst :: String -> Value -> Env -> Env
extendConst id val env = extendVar id val NoneP env

extendVar :: String -> Value -> Pattern -> Env -> Env
extendVar id val pat env@Env {idxs = idxs} =
  let Just (fun, funs) = uncons idxs
      Just (blk, blks) = uncons fun
   in env {idxs = (((id, (val, pat)):blk):blks):funs}

setVar :: String -> Value -> Env -> Env
setVar id val env@Env {idxs = idxs} =
  env {idxs = (replace id val (head idxs)):(tail idxs) }
  where
    replace :: Eq a => a -> b -> [[(a, (b, c))]] -> [[(a, (b, c))]]
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

boxValue :: Value -> Env -> (Env, Int)
boxValue val env@Env {vals = vals} =
  let idx = length vals
   in (env {vals = val:vals}, idx)

unboxValue :: Int -> Env -> Value
unboxValue idx env@Env {vals = vals} = vals!!(length vals - idx - 1)

setBox :: Int -> Value -> Env -> Env
setBox idx val env@Env {vals = vals} =
  env {vals = setElem vals (length vals - idx - 1) val}
  where
    setElem :: [a] -> Int -> a -> [a]
    setElem xs i x = let (h, t:ts) = splitAt i xs
                      in h ++ x:ts

-- functions and closures

getClosure :: Env -> [(String, Value)]
getClosure Env {idxs = idxs} = map (\(s, (v, _)) -> (s, v)) (concat $ head idxs)

--instance Show Env where
--  show = undefined
