{-
    BNF Converter: GADT Template Generator
    Copyright (C) 2004-2005  Author:  Markus Forberg, Björn Bringert

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


module BNFC.Backend.HaskellGADT.CFtoTemplateGADT (cf2Template) where

import BNFC.CF
import BNFC.Utils((+++))
import Data.List (groupBy)

import BNFC.Backend.HaskellGADT.HaskellGADTCommon

type ModuleName = String

cf2Template :: ModuleName -> ModuleName -> CF -> String
cf2Template skelName absName cf = unlines $ concat
  [ [ "{-# LANGUAGE GADTs #-}"
    , "{-# LANGUAGE EmptyCase #-}"
    , ""
    , "module "++ skelName ++ " where"
    , ""
    , "-- Haskell module generated by the BNF converter"
    , ""
    , "import " ++ absName
    , ""
    , "type Err = Either String"
    , "type Result = Err String"
    , ""
    , "failure :: Show a => a -> Result"
    , "failure x = Left $ \"Undefined case: \" ++ show x"
    , ""
    , "transTree :: Tree c -> Result"
    , "transTree t = case t of"
    ]
  , map prConsCase (cf2cons cf)
  , [ "" ]
  , concatMap ((++ [""]) . uncurry prCatTrans) (catCons cf)
  ]

prConsCase :: Constructor -> String
prConsCase c =
  "  " ++ consFun c +++ unwords (map snd (consVars c)) +++ "-> failure t"

catCons :: CF -> [(Cat,[Constructor])]
catCons cf = [ (consCat (head cs),cs) | cs <- groupBy catEq $ cf2cons cf]

catEq :: Constructor -> Constructor -> Bool
catEq c1 c2 = consCat c1 == consCat c2

prCatTrans :: Cat -> [Constructor] -> [String]
prCatTrans cat cs = ["trans" ++ show cat +++ "::" +++ show cat +++ "-> Result"
                    , "trans" ++ show cat +++ "t = case t of"]
                    ++ map prConsCase cs
