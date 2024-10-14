module Environment where

import Value

data Env = Env { idxs :: [(String, Value)]
               , vals :: [Value]
               }

emptyEnv :: Env
emptyEnv = Env [] []

lookupEnv :: String -> Env -> Maybe Value
lookupEnv id (Env idxs _) = lookup id idxs

lookupIdx :: Int -> Env -> Maybe Value
lookupIdx idx (Env _ vals) = return $ vals!!(length vals - idx - 1)

--setEnv :: String -> Value -> Env -> Maybe Env
--setEnv id val env@(Env xs) = do
--  _ <- lookupEnv id env
--  return $ Env $ rep xs id val
--  where
--    rep :: Eq a => [(a, b)] -> a -> b -> [(a, b)]
--    rep [] _ _ = []
--    rep ((a, b):xs) x y
--        | a == x    = (x, y) : xs
--        | otherwise = (a, b) : rep xs x y

extendConst :: String -> Value -> Env -> Env
extendConst id val env@Env {idxs = idxs} = env {idxs = (id, val):idxs}

extendVar :: String -> Value -> Env -> (Env, Value)
extendVar id val env@Env {idxs = idxs, vals = vals} =
  let newIdx = length vals
      val'   = ValVar newIdx
   in (env {idxs = (id, val'):idxs, vals = val:vals}, val')

setFromIdx :: Int -> Value -> Env -> Env
setFromIdx idx val env@Env {vals = vals} =
  env {vals = setElem vals (length vals - idx - 1) val}
  where
    setElem :: [a] -> Int -> a -> [a]
    setElem xs i x = let (h, t:ts) = splitAt i xs
                      in h ++ x:ts

instance Show Env where
  show (Env idx vals) = show idx ++ show vals
--  show (Env idx vals) = unlines $ map go es
--    where
--      go (id, val) = unwords [id, ":", show (typeof val), "=", show val]
