module Environment where

import Value

data Env = Env { idxs :: [(String, (Value, Bool))]
               , vals :: [Value]
               }

emptyEnv :: Env
emptyEnv = Env [] []

lookupEnv :: String -> Env -> Maybe (Value, Bool)
lookupEnv id (Env idxs _) = lookup id idxs

extendConst :: String -> Value -> Env -> Env
extendConst id val env@Env {idxs = idxs} = env {idxs = (id, (val, False)):idxs}

extendVar :: String -> Value -> Env -> Env
extendVar id val env@Env {idxs = idxs} = env {idxs = (id, (val, True)):idxs}

setVar :: String -> Value -> Env -> Env
setVar id val env@Env {idxs = idxs} = env {idxs = rep idxs id (val, True)}
  where
    rep :: Eq a => [(a, b)] -> a -> b -> [(a, b)]
    rep [] _ _ = []
    rep ((a, b):xs) x y
        | a == x    = (x, y) : xs
        | otherwise = (a, b) : rep xs x y

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
  show (Env idxs vals) = unlines $ map go idxs
    where
      go (id, (val, _)) = unwords [id, "=", show val]
