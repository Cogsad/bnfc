{-
    BNF Converter: GF generator
    Copyright (C) 2004  Author:  Markus Forberg, Aarne Ranta

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1335, USA
-}

module CFtoGF (
	      cf2AbsGF,
	      cf2ConcGF
              )where

import BNFC.CF
import List(intersperse,nub)

automessage :: String
automessage = "-- GF grammar automatically generated by BNF Converter.\n"

cf2AbsGF :: String -> CF -> String
cf2AbsGF name cf = unlines
		   [
		   automessage,
		   prCats cf,
		   prFuns cf,
		   prListFuns cf
		   ]

cf2ConcGF :: String -> CF -> String
cf2ConcGF name cf = unlines
		    [
		    automessage,
		    "include " ++ name ++ ".Abs.gf;\n",
		    if precCF cf then prPrec cf else [],
		    prLin cf,
		    prListLins cf
		    ]

prCats :: CF -> String
prCats cf = "cat \n" ++
	     unlines ["  " ++ cat ++ ";"
	              | cat <- nub $ map pr (reallyAllCats cf ++ literals cf),
	                not (cat =="String")] ++ "\n"

pr :: Cat -> String
pr cat
 | isList cat = identCat $ normCat cat
 | otherwise  = normCat cat

prFuns :: CF -> String
prFuns cf = "fun \n" ++
	    unlines [" " ++ f ++ "GF" ++ " : " ++ concat (intersperse " -> "
                     (map pr ys ++ [pr cat])) ++ ";" | (cat,xs) <- cf2data cf,
		  					 (f,ys) <- xs]

prListFuns :: CF -> String
prListFuns cf = unlines $ map listfun $ nub [ pr cat | cat <- reallyAllCats cf, isList cat]
 where listfun c = concat [" ", c , "E: " ,c ,";\n" , " ",
	                   c ,"Cons: ", (drop 4 c) , " -> ", c, " -> " , c, ";"]

prLin :: CF -> String
prLin cf = "lin\n" ++ unlines
	              [ let rhs = rhsRule r; as  = args rhs in
		        " " ++ funRule r ++ "GF " ++ unwords as ++ " = " ++
			lin r rhs as  | r <- rulesOfCF cf,
			                     isParsable r,
			                     let f = funRule r in not (isNilCons f || isCoercion f)]
  where args xs = [ "x" ++ show n | (_,n)<- zip (filter isLeft xs) [0 :: Int ..]]
	isLeft (Left _) = True
	isLeft _        = False
	lin r xs ys  = (if (precCF cf) then
		         "mkPrec p" ++ show (precRule r) ++ " (" ++ prec xs ys ++ ")"
			  else noPrec xs ys) ++" ; "
	noPrec xs ys = (if (null xs) then "\"\"" else (unwords (intersperse "++" (linNoPrec xs ys))))
	prec   xs ys = (if (null xs) then "\"\"" else (unwords (intersperse "++" (linPrec xs ys))))
	linNoPrec  [] _ = []
	linNoPrec  ((Left x):xs) (y:ys) = (y ++".s "): linNoPrec xs ys
	linNoPrec  ((Right x):xs) ys    = ("\"" ++ fixLambda x ++ "\"") : linNoPrec xs ys
	linPrec  [] _ = []
	linPrec  ((Left x):xs) (y:ys) = ("usePrec p" ++ show (precCat x) ++ " " ++ y): linPrec xs ys
	linPrec  ((Right x):xs) ys    = ("\"" ++ fixLambda x ++ "\"") : linPrec xs ys
	fixLambda "\\" = "\\\\"
	fixLambda    x = x

prListLins :: CF -> String
prListLins cf = unlines $ map listlin $ nub [ pr cat | cat <- reallyAllCats cf, isList cat]
 where listlin cat = concat [" ",cat, "E = { s = \"\" };\n", " ",  -- empty list
	                     cat ,"Cons x y = { s = x.s ++ y.s };"] -- cons

prPrec :: CF -> String
prPrec cf = unlines [
		     params,
		     booleans,
		     ltPrec,
		     opers,
		     lintypes
		    ]
 where booleans = unlines [
			   "param Bool = True | False ;",
			   "",
			   "oper",
			   "  if_then_else : (A : Type) -> Bool -> A -> A -> A = \\_,b,c,d ->",
			   "   case b of {",
			   "    True  => c ;",
			   "    False => d",
			   "   } ;"
			   ]
       precs  =  ["p" ++ show n | n <- precLevels cf]
       params = "param\n  Prec = " ++ unwords (intersperse "|" precs) ++ ";\n"
       ltPrec = unlines
		[
		 "ltPrec : Prec -> Prec -> Bool = \\i,j -> case <i,j> of {",
		 compPrec ++ " } ; "
                ]
       compPrec = concat $
		  intersperse (" ;\n") [
					"  <" ++ p1 ++ "," ++ p2 ++ "> => " ++ show (p1 < p2) |
					p1 <- precs,
					p2 <- precs
				       ]
       opers  = unlines
		[
		 "prPrec : Prec -> Prec -> Str -> Str = \\i,j,s ->",
		 "  if_then_else Str (ltPrec j i) (mkParenth s) s ;",
		 "",
		 "mkParenth : Str -> Str = \\s -> \"{\" ++ s ++ \"}\" ; ",
		 "",
		 "mkPrec : Prec -> Str -> {s : Prec => Str} = \\p,str ->",
		 "{s= \\\\q => if_then_else Str (ltPrec p q)",
		 "       (mkParenth str)",
		 "       str };",
		 "",
		 "usePrec : Prec -> {s: Prec => Str} -> Str = \\p,pstr -> ",
		 " pstr.s ! p;"
		]
       mkP p = concat $ intersperse ";\n"
	       ["   " ++ p' ++ " => " ++ if (p < p') then "mkParenth str" else "str" | p' <- precs]
       lintypes = unlines ["lincat " ++ c ++ " = {s : Prec => Str};" |
			    c <- nub $ map pr $ filter (not . isList) $ reallyAllCats cf ++ literals cf,
			    c /= "String"
			  ]
