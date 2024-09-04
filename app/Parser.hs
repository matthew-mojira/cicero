{-# OPTIONS_GHC -w #-}
module Parser where

import Lexer
import Token
import AST
import Value
import qualified Data.Array as Happy_Data_Array
import qualified Data.Bits as Bits
import Control.Applicative(Applicative(..))
import Control.Monad (ap)

-- parser produced by Happy Version 1.20.1.1

data HappyAbsSyn t4
	= HappyTerminal (TokenPosn)
	| HappyErrorToken Prelude.Int
	| HappyAbsSyn4 t4

happyExpList :: Happy_Data_Array.Array Prelude.Int Prelude.Int
happyExpList = Happy_Data_Array.listArray (0,103) ([16416,39,128,0,65024,775,4096,256,314,0,0,8192,10048,0,64512,1583,0,512,628,14849,129,16541,20096,16416,4135,5024,53256,1033,1256,29698,258,33082,40192,32832,61518,2111,8184,15360,0,30,3840,32768,7,62400,57344,121,0,0,0,48,6144,0,0,0,0
	])

{-# NOINLINE happyExpListPerState #-}
happyExpListPerState st =
    token_strs_expected
  where token_strs = ["error","%dummy","%start_runHappy","expr","'+'","'-'","'*'","'/'","'='","'!='","'<'","'<='","'>'","'>='","'('","')'","int","true","false","and","or","not","%eof"]
        bit_start = st Prelude.* 23
        bit_end = (st Prelude.+ 1) Prelude.* 23
        read_bit = readArrayBit happyExpList
        bits = Prelude.map read_bit [bit_start..bit_end Prelude.- 1]
        bits_indexed = Prelude.zip bits [0..22]
        token_strs_expected = Prelude.concatMap f bits_indexed
        f (Prelude.False, _) = []
        f (Prelude.True, nr) = [token_strs Prelude.!! nr]

action_0 (6) = happyShift action_4
action_0 (15) = happyShift action_5
action_0 (17) = happyShift action_2
action_0 (18) = happyShift action_6
action_0 (19) = happyShift action_7
action_0 (22) = happyShift action_8
action_0 (4) = happyGoto action_3
action_0 _ = happyFail (happyExpListPerState 0)

action_1 (17) = happyShift action_2
action_1 _ = happyFail (happyExpListPerState 1)

action_2 _ = happyReduce_1

action_3 (5) = happyShift action_12
action_3 (6) = happyShift action_13
action_3 (7) = happyShift action_14
action_3 (8) = happyShift action_15
action_3 (9) = happyShift action_16
action_3 (10) = happyShift action_17
action_3 (11) = happyShift action_18
action_3 (12) = happyShift action_19
action_3 (13) = happyShift action_20
action_3 (14) = happyShift action_21
action_3 (20) = happyShift action_22
action_3 (21) = happyShift action_23
action_3 (23) = happyAccept
action_3 _ = happyFail (happyExpListPerState 3)

action_4 (17) = happyShift action_11
action_4 _ = happyFail (happyExpListPerState 4)

action_5 (6) = happyShift action_4
action_5 (15) = happyShift action_5
action_5 (17) = happyShift action_2
action_5 (18) = happyShift action_6
action_5 (19) = happyShift action_7
action_5 (22) = happyShift action_8
action_5 (4) = happyGoto action_10
action_5 _ = happyFail (happyExpListPerState 5)

action_6 _ = happyReduce_17

action_7 _ = happyReduce_18

action_8 (6) = happyShift action_4
action_8 (15) = happyShift action_5
action_8 (17) = happyShift action_2
action_8 (18) = happyShift action_6
action_8 (19) = happyShift action_7
action_8 (22) = happyShift action_8
action_8 (4) = happyGoto action_9
action_8 _ = happyFail (happyExpListPerState 8)

action_9 _ = happyReduce_14

action_10 (5) = happyShift action_12
action_10 (6) = happyShift action_13
action_10 (7) = happyShift action_14
action_10 (8) = happyShift action_15
action_10 (9) = happyShift action_16
action_10 (10) = happyShift action_17
action_10 (11) = happyShift action_18
action_10 (12) = happyShift action_19
action_10 (13) = happyShift action_20
action_10 (14) = happyShift action_21
action_10 (16) = happyShift action_36
action_10 (20) = happyShift action_22
action_10 (21) = happyShift action_23
action_10 _ = happyFail (happyExpListPerState 10)

action_11 _ = happyReduce_16

action_12 (6) = happyShift action_4
action_12 (15) = happyShift action_5
action_12 (17) = happyShift action_2
action_12 (18) = happyShift action_6
action_12 (19) = happyShift action_7
action_12 (22) = happyShift action_8
action_12 (4) = happyGoto action_35
action_12 _ = happyFail (happyExpListPerState 12)

action_13 (6) = happyShift action_4
action_13 (15) = happyShift action_5
action_13 (17) = happyShift action_2
action_13 (18) = happyShift action_6
action_13 (19) = happyShift action_7
action_13 (22) = happyShift action_8
action_13 (4) = happyGoto action_34
action_13 _ = happyFail (happyExpListPerState 13)

action_14 (6) = happyShift action_4
action_14 (15) = happyShift action_5
action_14 (17) = happyShift action_2
action_14 (18) = happyShift action_6
action_14 (19) = happyShift action_7
action_14 (22) = happyShift action_8
action_14 (4) = happyGoto action_33
action_14 _ = happyFail (happyExpListPerState 14)

action_15 (6) = happyShift action_4
action_15 (15) = happyShift action_5
action_15 (17) = happyShift action_2
action_15 (18) = happyShift action_6
action_15 (19) = happyShift action_7
action_15 (22) = happyShift action_8
action_15 (4) = happyGoto action_32
action_15 _ = happyFail (happyExpListPerState 15)

action_16 (6) = happyShift action_4
action_16 (15) = happyShift action_5
action_16 (17) = happyShift action_2
action_16 (18) = happyShift action_6
action_16 (19) = happyShift action_7
action_16 (22) = happyShift action_8
action_16 (4) = happyGoto action_31
action_16 _ = happyFail (happyExpListPerState 16)

action_17 (6) = happyShift action_4
action_17 (15) = happyShift action_5
action_17 (17) = happyShift action_2
action_17 (18) = happyShift action_6
action_17 (19) = happyShift action_7
action_17 (22) = happyShift action_8
action_17 (4) = happyGoto action_30
action_17 _ = happyFail (happyExpListPerState 17)

action_18 (6) = happyShift action_4
action_18 (15) = happyShift action_5
action_18 (17) = happyShift action_2
action_18 (18) = happyShift action_6
action_18 (19) = happyShift action_7
action_18 (22) = happyShift action_8
action_18 (4) = happyGoto action_29
action_18 _ = happyFail (happyExpListPerState 18)

action_19 (6) = happyShift action_4
action_19 (15) = happyShift action_5
action_19 (17) = happyShift action_2
action_19 (18) = happyShift action_6
action_19 (19) = happyShift action_7
action_19 (22) = happyShift action_8
action_19 (4) = happyGoto action_28
action_19 _ = happyFail (happyExpListPerState 19)

action_20 (6) = happyShift action_4
action_20 (15) = happyShift action_5
action_20 (17) = happyShift action_2
action_20 (18) = happyShift action_6
action_20 (19) = happyShift action_7
action_20 (22) = happyShift action_8
action_20 (4) = happyGoto action_27
action_20 _ = happyFail (happyExpListPerState 20)

action_21 (6) = happyShift action_4
action_21 (15) = happyShift action_5
action_21 (17) = happyShift action_2
action_21 (18) = happyShift action_6
action_21 (19) = happyShift action_7
action_21 (22) = happyShift action_8
action_21 (4) = happyGoto action_26
action_21 _ = happyFail (happyExpListPerState 21)

action_22 (6) = happyShift action_4
action_22 (15) = happyShift action_5
action_22 (17) = happyShift action_2
action_22 (18) = happyShift action_6
action_22 (19) = happyShift action_7
action_22 (22) = happyShift action_8
action_22 (4) = happyGoto action_25
action_22 _ = happyFail (happyExpListPerState 22)

action_23 (6) = happyShift action_4
action_23 (15) = happyShift action_5
action_23 (17) = happyShift action_2
action_23 (18) = happyShift action_6
action_23 (19) = happyShift action_7
action_23 (22) = happyShift action_8
action_23 (4) = happyGoto action_24
action_23 _ = happyFail (happyExpListPerState 23)

action_24 (5) = happyShift action_12
action_24 (6) = happyShift action_13
action_24 (7) = happyShift action_14
action_24 (8) = happyShift action_15
action_24 (9) = happyShift action_16
action_24 (10) = happyShift action_17
action_24 (11) = happyShift action_18
action_24 (12) = happyShift action_19
action_24 (13) = happyShift action_20
action_24 (14) = happyShift action_21
action_24 (20) = happyShift action_22
action_24 _ = happyReduce_7

action_25 (5) = happyShift action_12
action_25 (6) = happyShift action_13
action_25 (7) = happyShift action_14
action_25 (8) = happyShift action_15
action_25 (9) = happyShift action_16
action_25 (10) = happyShift action_17
action_25 (11) = happyShift action_18
action_25 (12) = happyShift action_19
action_25 (13) = happyShift action_20
action_25 (14) = happyShift action_21
action_25 _ = happyReduce_6

action_26 (5) = happyShift action_12
action_26 (6) = happyShift action_13
action_26 (7) = happyShift action_14
action_26 (8) = happyShift action_15
action_26 _ = happyReduce_13

action_27 (5) = happyShift action_12
action_27 (6) = happyShift action_13
action_27 (7) = happyShift action_14
action_27 (8) = happyShift action_15
action_27 _ = happyReduce_12

action_28 (5) = happyShift action_12
action_28 (6) = happyShift action_13
action_28 (7) = happyShift action_14
action_28 (8) = happyShift action_15
action_28 _ = happyReduce_11

action_29 (5) = happyShift action_12
action_29 (6) = happyShift action_13
action_29 (7) = happyShift action_14
action_29 (8) = happyShift action_15
action_29 _ = happyReduce_10

action_30 (5) = happyShift action_12
action_30 (6) = happyShift action_13
action_30 (7) = happyShift action_14
action_30 (8) = happyShift action_15
action_30 (11) = happyShift action_18
action_30 (12) = happyShift action_19
action_30 (13) = happyShift action_20
action_30 (14) = happyShift action_21
action_30 _ = happyReduce_9

action_31 (5) = happyShift action_12
action_31 (6) = happyShift action_13
action_31 (7) = happyShift action_14
action_31 (8) = happyShift action_15
action_31 (11) = happyShift action_18
action_31 (12) = happyShift action_19
action_31 (13) = happyShift action_20
action_31 (14) = happyShift action_21
action_31 _ = happyReduce_8

action_32 _ = happyReduce_5

action_33 _ = happyReduce_4

action_34 (7) = happyShift action_14
action_34 (8) = happyShift action_15
action_34 _ = happyReduce_3

action_35 (7) = happyShift action_14
action_35 (8) = happyShift action_15
action_35 _ = happyReduce_2

action_36 _ = happyReduce_15

happyReduce_1 = happySpecReduce_1  4 happyReduction_1
happyReduction_1 (HappyTerminal (TokenPosn (TokInt happy_var_1) _))
	 =  HappyAbsSyn4
		 (ExprLit (ValInt happy_var_1)
	)
happyReduction_1 _  = notHappyAtAll 

happyReduce_2 = happySpecReduce_3  4 happyReduction_2
happyReduction_2 (HappyAbsSyn4  happy_var_3)
	_
	(HappyAbsSyn4  happy_var_1)
	 =  HappyAbsSyn4
		 (ExprBinOp Add happy_var_1 happy_var_3
	)
happyReduction_2 _ _ _  = notHappyAtAll 

happyReduce_3 = happySpecReduce_3  4 happyReduction_3
happyReduction_3 (HappyAbsSyn4  happy_var_3)
	_
	(HappyAbsSyn4  happy_var_1)
	 =  HappyAbsSyn4
		 (ExprBinOp Sub happy_var_1 happy_var_3
	)
happyReduction_3 _ _ _  = notHappyAtAll 

happyReduce_4 = happySpecReduce_3  4 happyReduction_4
happyReduction_4 (HappyAbsSyn4  happy_var_3)
	_
	(HappyAbsSyn4  happy_var_1)
	 =  HappyAbsSyn4
		 (ExprBinOp Mult happy_var_1 happy_var_3
	)
happyReduction_4 _ _ _  = notHappyAtAll 

happyReduce_5 = happySpecReduce_3  4 happyReduction_5
happyReduction_5 (HappyAbsSyn4  happy_var_3)
	_
	(HappyAbsSyn4  happy_var_1)
	 =  HappyAbsSyn4
		 (ExprBinOp Div happy_var_1 happy_var_3
	)
happyReduction_5 _ _ _  = notHappyAtAll 

happyReduce_6 = happySpecReduce_3  4 happyReduction_6
happyReduction_6 (HappyAbsSyn4  happy_var_3)
	_
	(HappyAbsSyn4  happy_var_1)
	 =  HappyAbsSyn4
		 (ExprBinOp LAnd happy_var_1 happy_var_3
	)
happyReduction_6 _ _ _  = notHappyAtAll 

happyReduce_7 = happySpecReduce_3  4 happyReduction_7
happyReduction_7 (HappyAbsSyn4  happy_var_3)
	_
	(HappyAbsSyn4  happy_var_1)
	 =  HappyAbsSyn4
		 (ExprBinOp LOr happy_var_1 happy_var_3
	)
happyReduction_7 _ _ _  = notHappyAtAll 

happyReduce_8 = happySpecReduce_3  4 happyReduction_8
happyReduction_8 (HappyAbsSyn4  happy_var_3)
	_
	(HappyAbsSyn4  happy_var_1)
	 =  HappyAbsSyn4
		 (ExprBinOp Eq happy_var_1 happy_var_3
	)
happyReduction_8 _ _ _  = notHappyAtAll 

happyReduce_9 = happySpecReduce_3  4 happyReduction_9
happyReduction_9 (HappyAbsSyn4  happy_var_3)
	_
	(HappyAbsSyn4  happy_var_1)
	 =  HappyAbsSyn4
		 (ExprBinOp Neq happy_var_1 happy_var_3
	)
happyReduction_9 _ _ _  = notHappyAtAll 

happyReduce_10 = happySpecReduce_3  4 happyReduction_10
happyReduction_10 (HappyAbsSyn4  happy_var_3)
	_
	(HappyAbsSyn4  happy_var_1)
	 =  HappyAbsSyn4
		 (ExprBinOp Le happy_var_1 happy_var_3
	)
happyReduction_10 _ _ _  = notHappyAtAll 

happyReduce_11 = happySpecReduce_3  4 happyReduction_11
happyReduction_11 (HappyAbsSyn4  happy_var_3)
	_
	(HappyAbsSyn4  happy_var_1)
	 =  HappyAbsSyn4
		 (ExprBinOp Leq happy_var_1 happy_var_3
	)
happyReduction_11 _ _ _  = notHappyAtAll 

happyReduce_12 = happySpecReduce_3  4 happyReduction_12
happyReduction_12 (HappyAbsSyn4  happy_var_3)
	_
	(HappyAbsSyn4  happy_var_1)
	 =  HappyAbsSyn4
		 (ExprBinOp Ge happy_var_1 happy_var_3
	)
happyReduction_12 _ _ _  = notHappyAtAll 

happyReduce_13 = happySpecReduce_3  4 happyReduction_13
happyReduction_13 (HappyAbsSyn4  happy_var_3)
	_
	(HappyAbsSyn4  happy_var_1)
	 =  HappyAbsSyn4
		 (ExprBinOp Geq happy_var_1 happy_var_3
	)
happyReduction_13 _ _ _  = notHappyAtAll 

happyReduce_14 = happySpecReduce_2  4 happyReduction_14
happyReduction_14 (HappyAbsSyn4  happy_var_2)
	_
	 =  HappyAbsSyn4
		 (ExprUnOp LNot happy_var_2
	)
happyReduction_14 _ _  = notHappyAtAll 

happyReduce_15 = happySpecReduce_3  4 happyReduction_15
happyReduction_15 _
	(HappyAbsSyn4  happy_var_2)
	_
	 =  HappyAbsSyn4
		 (happy_var_2
	)
happyReduction_15 _ _ _  = notHappyAtAll 

happyReduce_16 = happySpecReduce_2  4 happyReduction_16
happyReduction_16 (HappyTerminal (TokenPosn (TokInt happy_var_2) _))
	_
	 =  HappyAbsSyn4
		 (ExprLit $ (ValInt $ -happy_var_2)
	)
happyReduction_16 _ _  = notHappyAtAll 

happyReduce_17 = happySpecReduce_1  4 happyReduction_17
happyReduction_17 _
	 =  HappyAbsSyn4
		 (ExprLit (ValBool True)
	)

happyReduce_18 = happySpecReduce_1  4 happyReduction_18
happyReduction_18 _
	 =  HappyAbsSyn4
		 (ExprLit (ValBool False)
	)

happyNewToken action sts stk
	= lexwrap(\tk -> 
	let cont i = action i i tk (HappyState action) sts stk in
	case tk of {
	Eof -> action 23 23 tk (HappyState action) sts stk;
	TokenPosn TokPlus _ -> cont 5;
	TokenPosn TokMinus _ -> cont 6;
	TokenPosn TokStar _ -> cont 7;
	TokenPosn TokBackslash _ -> cont 8;
	TokenPosn TokEq -> cont 9;
	TokenPosn TokNeq -> cont 10;
	TokenPosn TokLe -> cont 11;
	TokenPosn TokLeq -> cont 12;
	TokenPosn TokGe -> cont 13;
	TokenPosn TokGeq -> cont 14;
	TokenPosn TokLParen _ -> cont 15;
	TokenPosn TokRParen _ -> cont 16;
	TokenPosn (TokInt happy_dollar_dollar) _ -> cont 17;
	TokenPosn TokTrue _ -> cont 18;
	TokenPosn TokFalse _ -> cont 19;
	TokenPosn TokAnd _ -> cont 20;
	TokenPosn TokOr _ -> cont 21;
	TokenPosn TokNot _ -> cont 22;
	_ -> happyError' (tk, [])
	})

happyError_ explist 23 tk = happyError' (tk, explist)
happyError_ explist _ tk = happyError' (tk, explist)

happyThen :: () => Alex a -> (a -> Alex b) -> Alex b
happyThen = (Prelude.>>=)
happyReturn :: () => a -> Alex a
happyReturn = (Prelude.return)
happyThen1 :: () => Alex a -> (a -> Alex b) -> Alex b
happyThen1 = happyThen
happyReturn1 :: () => a -> Alex a
happyReturn1 = happyReturn
happyError' :: () => ((TokenPosn), [Prelude.String]) -> Alex a
happyError' tk = (\(tokens, _) -> parseError tokens) tk
runHappy = happySomeParser where
 happySomeParser = happyThen (happyParse action_0) (\x -> case x of {HappyAbsSyn4 z -> happyReturn z; _other -> notHappyAtAll })

happySeq = happyDontSeq


lexwrap :: (TokenPosn -> Alex a) -> Alex a
lexwrap = (alexMonadScan >>=)

parseError :: TokenPosn -> Alex a
parseError (TokenPosn _ (AlexPn _ line col)) = alexError $ "parsing error at line " ++ show line ++ ", column " ++ show col

parse :: String -> Either String Prog
parse s = runAlex s runHappy
{-# LINE 1 "templates/GenericTemplate.hs" #-}
-- $Id: GenericTemplate.hs,v 1.26 2005/01/14 14:47:22 simonmar Exp $










































data Happy_IntList = HappyCons Prelude.Int Happy_IntList








































infixr 9 `HappyStk`
data HappyStk a = HappyStk a (HappyStk a)

-----------------------------------------------------------------------------
-- starting the parse

happyParse start_state = happyNewToken start_state notHappyAtAll notHappyAtAll

-----------------------------------------------------------------------------
-- Accepting the parse

-- If the current token is ERROR_TOK, it means we've just accepted a partial
-- parse (a %partial parser).  We must ignore the saved token on the top of
-- the stack in this case.
happyAccept (1) tk st sts (_ `HappyStk` ans `HappyStk` _) =
        happyReturn1 ans
happyAccept j tk st sts (HappyStk ans _) = 
         (happyReturn1 ans)

-----------------------------------------------------------------------------
-- Arrays only: do the next action









































indexShortOffAddr arr off = arr Happy_Data_Array.! off


{-# INLINE happyLt #-}
happyLt x y = (x Prelude.< y)






readArrayBit arr bit =
    Bits.testBit (indexShortOffAddr arr (bit `Prelude.div` 16)) (bit `Prelude.mod` 16)






-----------------------------------------------------------------------------
-- HappyState data type (not arrays)



newtype HappyState b c = HappyState
        (Prelude.Int ->                    -- token number
         Prelude.Int ->                    -- token number (yes, again)
         b ->                           -- token semantic value
         HappyState b c ->              -- current state
         [HappyState b c] ->            -- state stack
         c)



-----------------------------------------------------------------------------
-- Shifting a token

happyShift new_state (1) tk st sts stk@(x `HappyStk` _) =
     let i = (case x of { HappyErrorToken (i) -> i }) in
--     trace "shifting the error token" $
     new_state i i tk (HappyState (new_state)) ((st):(sts)) (stk)

happyShift new_state i tk st sts stk =
     happyNewToken new_state ((st):(sts)) ((HappyTerminal (tk))`HappyStk`stk)

-- happyReduce is specialised for the common cases.

happySpecReduce_0 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_0 nt fn j tk st@((HappyState (action))) sts stk
     = action nt j tk st ((st):(sts)) (fn `HappyStk` stk)

happySpecReduce_1 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_1 nt fn j tk _ sts@(((st@(HappyState (action))):(_))) (v1`HappyStk`stk')
     = let r = fn v1 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_2 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_2 nt fn j tk _ ((_):(sts@(((st@(HappyState (action))):(_))))) (v1`HappyStk`v2`HappyStk`stk')
     = let r = fn v1 v2 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_3 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_3 nt fn j tk _ ((_):(((_):(sts@(((st@(HappyState (action))):(_))))))) (v1`HappyStk`v2`HappyStk`v3`HappyStk`stk')
     = let r = fn v1 v2 v3 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happyReduce k i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyReduce k nt fn j tk st sts stk
     = case happyDrop (k Prelude.- ((1) :: Prelude.Int)) sts of
         sts1@(((st1@(HappyState (action))):(_))) ->
                let r = fn stk in  -- it doesn't hurt to always seq here...
                happyDoSeq r (action nt j tk st1 sts1 r)

happyMonadReduce k nt fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyMonadReduce k nt fn j tk st sts stk =
      case happyDrop k ((st):(sts)) of
        sts1@(((st1@(HappyState (action))):(_))) ->
          let drop_stk = happyDropStk k stk in
          happyThen1 (fn stk tk) (\r -> action nt j tk st1 sts1 (r `HappyStk` drop_stk))

happyMonad2Reduce k nt fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyMonad2Reduce k nt fn j tk st sts stk =
      case happyDrop k ((st):(sts)) of
        sts1@(((st1@(HappyState (action))):(_))) ->
         let drop_stk = happyDropStk k stk





             _ = nt :: Prelude.Int
             new_state = action

          in
          happyThen1 (fn stk tk) (\r -> happyNewToken new_state sts1 (r `HappyStk` drop_stk))

happyDrop (0) l = l
happyDrop n ((_):(t)) = happyDrop (n Prelude.- ((1) :: Prelude.Int)) t

happyDropStk (0) l = l
happyDropStk n (x `HappyStk` xs) = happyDropStk (n Prelude.- ((1)::Prelude.Int)) xs

-----------------------------------------------------------------------------
-- Moving to a new state after a reduction









happyGoto action j tk st = action j j tk (HappyState action)


-----------------------------------------------------------------------------
-- Error recovery (ERROR_TOK is the error token)

-- parse error if we are in recovery and we fail again
happyFail explist (1) tk old_st _ stk@(x `HappyStk` _) =
     let i = (case x of { HappyErrorToken (i) -> i }) in
--      trace "failing" $ 
        happyError_ explist i tk

{-  We don't need state discarding for our restricted implementation of
    "error".  In fact, it can cause some bogus parses, so I've disabled it
    for now --SDM

-- discard a state
happyFail  ERROR_TOK tk old_st CONS(HAPPYSTATE(action),sts) 
                                                (saved_tok `HappyStk` _ `HappyStk` stk) =
--      trace ("discarding state, depth " ++ show (length stk))  $
        DO_ACTION(action,ERROR_TOK,tk,sts,(saved_tok`HappyStk`stk))
-}

-- Enter error recovery: generate an error token,
--                       save the old token and carry on.
happyFail explist i tk (HappyState (action)) sts stk =
--      trace "entering error recovery" $
        action (1) (1) tk (HappyState (action)) sts ((HappyErrorToken (i)) `HappyStk` stk)

-- Internal happy errors:

notHappyAtAll :: a
notHappyAtAll = Prelude.error "Internal Happy error\n"

-----------------------------------------------------------------------------
-- Hack to get the typechecker to accept our action functions







-----------------------------------------------------------------------------
-- Seq-ing.  If the --strict flag is given, then Happy emits 
--      happySeq = happyDoSeq
-- otherwise it emits
--      happySeq = happyDontSeq

happyDoSeq, happyDontSeq :: a -> b -> b
happyDoSeq   a b = a `Prelude.seq` b
happyDontSeq a b = b

-----------------------------------------------------------------------------
-- Don't inline any functions from the template.  GHC has a nasty habit
-- of deciding to inline happyGoto everywhere, which increases the size of
-- the generated parser quite a bit.









{-# NOINLINE happyShift #-}
{-# NOINLINE happySpecReduce_0 #-}
{-# NOINLINE happySpecReduce_1 #-}
{-# NOINLINE happySpecReduce_2 #-}
{-# NOINLINE happySpecReduce_3 #-}
{-# NOINLINE happyReduce #-}
{-# NOINLINE happyMonadReduce #-}
{-# NOINLINE happyGoto #-}
{-# NOINLINE happyFail #-}

-- end of Happy Template.
