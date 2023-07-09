{-# LANGUAGE CPP #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TupleSections #-}

-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if 900 >= 800-- #if __GLASGOW_HASKELL__ >= 800
-- {-# OPTIONS_GHC -fno-warn-unused-top-binds #-}
-- #endif

-- | Agda backend.
--
-- Generate bindings to Haskell data types for use in Agda.
--
-- Example for abstract syntax generated in Haskell backend:
--
-- > module CPP.Abs where
-- >
-- > import Prelude (Char, Double, Integer, String)
-- > import qualified Prelude as C (Eq, Ord, Show, Read)
-- >
-- > import qualified Data.Text
-- >
-- > newtype Ident = Ident Data.Text.Text
-- >   deriving (C.Eq, C.Ord, C.Show, C.Read)
-- >
-- > data Def = DFun Type Ident [Arg] [Stm]
-- >   deriving (C.Eq, C.Ord, C.Show, C.Read)
-- >
-- > data Arg = ADecl Type Ident
-- >   deriving (C.Eq, C.Ord, C.Show, C.Read)
-- >
-- > data Stm
-- >     = SExp Exp
-- >     | SInit Type Ident Exp
-- >     | SBlock [Stm]
-- >     | SIfElse Exp Stm Stm
-- >   deriving (C.Eq, C.Ord, C.Show, C.Read)
-- >
-- > data Exp
-- >
-- > data Type = Type_bool | Type_int | Type_double | Type_void
-- >   deriving (C.Eq, C.Ord, C.Show, C.Read)
--
-- This should be accompanied by the following Agda code:
--
-- > module CPP.AST where
-- >
-- > open import Agda.Builtin.Char using () renaming (Char to Char)
-- > open import Agda.Builtin.Float public using () renaming (Float to Double)
-- > open import Agda.Builtin.Int   public using () renaming (Int to Integer)
-- > open import Agda.Builtin.List using () renaming (List to #List)
-- > open import Agda.Builtin.String using () renaming
-- >   ( String to #String
-- >   ; primStringFromList to #stringFromList
-- >   )
-- >
-- > {-# FOREIGN GHC import Prelude (Char, Double, Integer, String) #-}
-- > {-# FOREIGN GHC import qualified Data.Text #-}
-- > {-# FOREIGN GHC import qualified CPP.Abs #-}
-- > {-# FOREIGN GHC import CPP.Print (printTree) #-}
-- >
-- > data Ident : Set where
-- >   ident : #String → Ident
-- >
-- > {-# COMPILE GHC Ident = data CPP.Abs.Ident (CPP.Abs.Ident) #-}
-- >
-- > data Def : Set where
-- >   dFun : (t : Type) (x : Ident) (as : List Arg) (ss : List Stm) → Def
-- >
-- > {-# COMPILE GHC Def = data CPP.Abs.Def (CPP.Abs.DFun) #-}
-- >
-- > data Arg : Set where
-- >   aDecl : (t : Type) (x : Ident) → Arg
-- >
-- > {-# COMPILE GHC Arg = data CPP.Abs.Arg (CPP.Abs.ADecl) #-}
-- >
-- > data Stm : Set where
-- >   sExp : (e : Exp) → Stm
-- >   sInit : (t : Type) (x : Ident) (e : Exp) → Stm
-- >   sBlock : (ss : List Stm) → Stm
-- >   sIfElse : (e : Exp) (s s' : Stm) → Stm
-- >
-- > {-# COMPILE GHC Stm = data CPP.Abs.Stm
-- >   ( CPP.Abs.SExp
-- >   | CPP.Abs.SInit
-- >   | CPP.Abs.SBlock
-- >   | CPP.Abs.SIfElse
-- >   ) #-}
-- >
-- > data Type : Set where
-- >   typeBool typeInt typeDouble typeVoid : Type
-- >
-- > {-# COMPILE GHC Type = data CPP.Abs.Type
-- >   ( CPP.Abs.Type_bool
-- >   | CPP.Abs.Type_int
-- >   | CPP.Abs.Type_double
-- >   | CPP.Abs.Type_void
-- >   ) #-}
-- >
-- > -- Binding the BNFC pretty printers.
-- >
-- > printIdent  : Ident → String
-- > printIdent (ident s) = String.fromList s
-- >
-- > postulate
-- >   printType    : Type    → String
-- >   printExp     : Exp     → String
-- >   printStm     : Stm     → String
-- >   printArg     : Arg     → String
-- >   printDef     : Def     → String
-- >   printProgram : Program → String
-- >
-- > {-# COMPILE GHC printType    = \ t -> Data.Text.pack (printTree (t :: CPP.Abs.Type)) #-}
-- > {-# COMPILE GHC printExp     = \ e -> Data.Text.pack (printTree (e :: CPP.Abs.Exp))  #-}
-- > {-# COMPILE GHC printStm     = \ s -> Data.Text.pack (printTree (s :: CPP.Abs.Stm))  #-}
-- > {-# COMPILE GHC printArg     = \ a -> Data.Text.pack (printTree (a :: CPP.Abs.Arg))  #-}
-- > {-# COMPILE GHC printDef     = \ d -> Data.Text.pack (printTree (d :: CPP.Abs.Def))  #-}
-- > {-# COMPILE GHC printProgram = \ p -> Data.Text.pack (printTree (p :: CPP.Abs.Program)) #-}

module BNFC.Backend.Agda2HS (makeAgda2HS) where

import Prelude hiding ((<>))
import Control.Monad.State hiding (when)
import Data.Bifunctor (second)
import Data.Char
import Data.Function (on)
import qualified Data.List as List
import Data.List.NonEmpty (NonEmpty((:|)))
import qualified Data.List.NonEmpty as List1
import Data.Map (Map)
import qualified Data.Map as Map
import Data.Maybe
import Data.Set (Set)
import qualified Data.Set as Set
import Data.String (IsString)

import BNFC.CF
import BNFC.Backend.Base                 (Backend, mkfile)
import BNFC.Backend.Haskell.HsOpts
import BNFC.Backend.Haskell.CFtoAbstract (DefCfg(..), definedRules')
import BNFC.Backend.Haskell.Utils        (parserName, catToType, comment , extractModName, genName, tokenTextType)
import BNFC.Options                      (SharedOptions, TokenText(..), tokenText, functor)
import BNFC.PrettyPrint
import BNFC.Utils                        (ModuleName, replace, when, table)

-- | How to print the types of constructors in Agda?

data ConstructorStyle
  = UnnamedArg  -- ^ Simply typed, like @E → S → S → S@.
  | NamedArg    -- ^ Dependently typed, like @(e : E) (s₁ s₂ : S) → S@.

-- | Import the builtin numeric types (content of some token categories)?

data ImportNumeric
  = YesImportNumeric  -- ^ Import the numeric types.
  | NoImportNumeric   -- ^ Don't import the numeric types.
  deriving (Eq)


data PragmaInfo
  = ErrData -- ^ Pragma type for the ErrM data type
  | DataData -- ^ Pragma for other data types
  | StringType TokenCat TokenText -- ^ Pragma for String types

-- | Entry-point for Agda backend.

makeAgda2HS
  :: String         -- ^ Current time.
  -> SharedOptions  -- ^ Options.
  -> CF             -- ^ Grammar.
  -> Backend
makeAgda2HS time opts cf = do
  -- Generate AST bindings.
  mkfile (agda2hsAbsFile opts) comment $
    cf2AgdaAST time (functor opts) (tokenText opts) (agda2hsAbsFileM opts) (absFileM opts) (printerFileM opts) cf
  -- Generate parser bindings.
  mkfile (agdaParserFile opts) comment $
    cf2AgdaParser time (tokenText opts) (agdaParserFileM opts) (agda2hsAbsFileM opts) (errFileM opts) (happyFileM opts)
      layoutMod
      parserCats
  -- Generate an I/O library for the test parser.
  mkfile (agdaLibFile opts) comment $
    agdaLibContents (agdaLibFileM opts)
  -- Generate test parser.
  mkfile (agdaMainFile opts) comment $
    agdaMainContents (agdaMainFileM opts) (agdaLibFileM opts) (agda2hsAbsFileM opts) (agdaParserFileM opts)
      (hasLayout cf)
      (firstEntry cf)
  where
  -- | Generate parsers for the following non-terminals.
  --   This includes parsers for 'CoercCat' and 'ListCat'.
  parserCats :: [Cat]
  parserCats = List1.toList $ allEntryPoints cf
  -- | In case the grammar makes use of layout, pass also the generated layout Haskell module.
  layoutMod :: Maybe String
  layoutMod = when (hasLayout cf) $ Just (layoutFileM opts)

-- | Generate AST bindings for Agda.
--
cf2AgdaAST
  :: String  -- ^ Current time.
  -> Bool    -- ^ Include positions information in the AST? (`--functor`)
  -> TokenText
  -> String  -- ^ Module name.
  -> String  -- ^ Haskell Abs module name.
  -> String  -- ^ Haskell Print module name.
  -> CF      -- ^ Grammar.
  -> Doc
cf2AgdaAST time havePos tokenText mod amod pmod cf = vsep
  [ preamble time "abstract syntax data types"
  , hsep [ "module", text mod, "where" ]
  , imports YesImportNumeric False usesPos havePos
  , when usesString $ hsep [ "String", equals, listT, charT ]
  , importPragmas tokenText usesPos [ unwords [ "qualified", amod ] ]
      --[ unwords [ "qualified", amod ]
      -- , unwords [ pmod, "(printTree)" ]
      -- ]
  , when usesPos defineIntAndPair
  , when havePos defineBNFCPosition
  , vsep $ map (uncurry $ prToken amod tokenText) tcats
  , absyn amod havePos NamedArg dats
  , definedRules havePos cf
  -- , allTokenCats printToken tcats  -- seem to be included in printerCats
  -- , printers amod printerCats Allegedaly not needed in AGDA2HS
  , empty -- Make sure we terminate the file with a new line.
  ]
  where
  -- The grammar categories (excluding list, coerce, and token categories):
  dats :: [Data]
  dats = cf2data cf
         -- getAbstractSyntax also includes list categories, which isn't what we need
  -- The user-defined token categories (including Ident).
  tcats :: [(TokenCat, Bool)]
  tcats = (if hasIdent cf then ((catIdent, False) :) else id)
    [ (wpThing name, b) | TokenReg name b _ <- cfgPragmas cf ]
  -- Bind printers for the following categories (involves lists and literals).
  printerCats :: [Cat]
  printerCats = map fst (getAbstractSyntax cf) ++ map TokenCat (List.nub $ cfgLiterals cf ++ map fst tcats)
  usesString = "String" `elem` cfgLiterals cf
  usesPos    = havePos || hasPositionTokens cf
  defineIntAndPair = vsep
    [ vcat ("postulate" : map (nest 2 . text) (table " "
        [ [ intT,      ":", "Set" ]
        , [ intToNatT, ":", intT, uArrow , natT ]
        , [ natToIntT, ":", natT, uArrow , intT ]
        ]))
    , vcat $ map (\ s -> hsep [ "{-#", "FOREIGN", "AGDA2HS", text s, "#-}" ]) $
        table " = "
        [ [ intT,      "type Prelude.Int"    ]
        , [ intToNatT, "Prelude.toInteger"   ]
        , [ natToIntT, "Prelude.fromInteger" ]
        ]
    , vcat
      [ "data #Pair (A B : Set) : Set where"
      , nest 2 "#pair : A → B → #Pair A B"
      ]
    , "{-# FOREIGN AGDA2HS #Pair = data (,) ((,)) #-}"
    ]
  defineBNFCPosition =
    hsep [ posT, equals, maybeT, parens intPairT ]

-- | Generate parser bindings for Agda.
--
cf2AgdaParser
  :: String  -- ^ Current time.
  -> TokenText
  -> String  -- ^ Module name.
  -> String  -- ^ Agda AST module name.
  -> String  -- ^ Haskell ErrM module name.
  -> String  -- ^ Haskell Par module name.
  -> Maybe String
             -- ^ Does the grammar use layout?  If yes, Haskell Layout module name.
  -> [Cat]   -- ^ Bind parsers for these non-terminals.
  -> Doc
cf2AgdaParser time tokenText mod astmod emod pmod layoutMod cats = vsep
  [ preamble time "parsers"
  , hsep [ "module", text mod, "where" ]
  , imports NoImportNumeric (isJust layoutMod) False False
  , importCats astmod (List.nub cs)
  , importPragmas tokenText False $ [ qual emod, pmod] ++ maybeToList (qual <$> layoutMod)
  , "-- Error monad of BNFC"
  , prErrM emod
  , "-- Happy parsers"
  , parsers tokenText layoutMod cats
  , empty -- Make sure we terminate the file with a new line.
  ]
  where
  cs :: [String]
  cs = mapMaybe baseCat cats
  baseCat :: Cat -> Maybe String
  baseCat = \case
    Cat s         -> Just s
    CoercCat s _  -> Just s
    TokenCat "Char" -> Nothing
    TokenCat s    -> Just s
    ListCat c     -> baseCat c
  qual m = "qualified " ++ m

-- We prefix the Agda types with "#" to not conflict with user-provided nonterminals.
uArrow, charT, integerT, doubleT, boolT, listT, maybeT, nothingT, justT,
  intT, natT, intToNatT, natToIntT, pairT, posT, stringT, stringFromListT
  :: IsString a => a
uArrow           = "→"
charT           = "Char"     -- This is the BNFC name for token type Char!
integerT        = "Integer"  -- This is the BNFC name for token type Integer!
doubleT         = "Double"   -- This is the BNFC name for token type Double!
boolT           = "#Bool"
listT           = "#List"
maybeT          = "#Maybe"
nothingT        = "#nothing"
justT           = "#just"
intT            = "#Int"     -- Int is the type used by the Haskell backend for line and column positions.
natT            = "#Nat"
intToNatT       = "#intToNat"
natToIntT       = "#natToInt"
pairT           = "#Pair"
posT            = "#BNFCPosition"
stringT         = "#String"
stringFromListT = "#stringFromList"

intPairT :: Doc
intPairT = hsep [ pairT, intT, intT ]

-- | Preamble: introductory comments.

preamble
  :: String  -- ^ Time stamp.
  -> String  -- ^ Brief characterization of file content.
  -> Doc
preamble _time what = vcat
  [ hcat [ "-- Agda bindings for the Haskell ", text what, "." ]
  -- -- Time stamp does not work well with BNFC's mkfile logic.
  -- , hcat [ "-- Generated by BNFC at "         , text time, "." ]
  ]

-- | Import statements.

imports
  :: ImportNumeric -- ^ Import also numeric types?
  -> Bool          -- ^ If have layout, import booleans.
  -> Bool          -- ^ If have position information, import natural numbers.
  -> Bool          -- ^ Do we need @Maybe@?
  -> Doc
imports numeric layout pos needMaybe = vcat . map prettyImport . concat $
  [ when layout
    [ ("Agda.Builtin.Bool",   [],            [("Bool", boolT)]) ]
  , [ ("Agda.Builtin.Char",   [charT],       []               ) ]
  , when (numeric == YesImportNumeric) importNumeric
  , [ ("Agda.Builtin.List",   ["[]", "_∷_"], [("List", listT)]) ]
  , when needMaybe
    [ ("Agda.Builtin.Maybe",  [], [("Maybe", maybeT), ("nothing", nothingT), ("just", justT)]) ]
  , when pos
    [ ("Agda.Builtin.Nat",    [],            [("Nat" , natT )]) ]
  , [ ("Agda.Builtin.String", [], [("String", stringT), ("primStringFromList", stringFromListT) ]) ]
  ]
  where
  importNumeric :: [(String, [Doc], [(String, Doc)])]
  importNumeric =
    [ ("Agda.Builtin.Float public", [], [("Float", doubleT)])
    , ("Agda.Builtin.Int   public", [], [("Int", integerT)])
    , ("Agda.Builtin.Int"         , [], [("pos", "#pos")])
    ]
  prettyImport :: (String, [Doc], [(String, Doc)]) -> Doc
  prettyImport (m, use, ren)
    | null ren  = pre
    | otherwise = prettyList 2 pre lparen rparen semi $
        map (\ (x, d) -> hsep [text x, "to", d ]) ren
    where
    pre = hsep $ concat
      [ [ "open", "import", text m ]
      , [ "using", parens $ hcat $ punctuate "; " use ]
      , [ "renaming" | not (null ren) ]
      ]

-- | Import Agda AST.
--
importCats
  :: String    -- ^ Module for Agda AST.
  -> [String]  -- ^ Agda data types to import.
  -> Doc
importCats m cs = prettyList 2 pre lparen rparen semi $ map text cs
  where
  pre = hsep [ "open", "import", text m, "using" ]

-- | Import pragmas.
--
-- >>> importPragmas ByteStringToken False ["qualified Foo.Abs", "Foo.Print (printTree)", "qualified Foo.Layout"]
-- {-# FOREIGN GHC import Prelude (Bool, Char, Double, Integer, String, (.)) #-}
-- {-# FOREIGN GHC import qualified Data.ByteString.Char8 as BS #-}
-- {-# FOREIGN GHC import qualified Data.Text #-}
-- {-# FOREIGN GHC import qualified Foo.Abs #-}
-- {-# FOREIGN GHC import Foo.Print (printTree) #-}
-- {-# FOREIGN GHC import qualified Foo.Layout #-}
--
importPragmas
  :: TokenText
  -> Bool      -- ^ Do we use position information?
  -> [String]  -- ^ Haskell modules to import.
  -> Doc
importPragmas tokenText pos mods = vcat $ map imp $ base
  where
  imp s = hsep [ "{-#", "FOREIGN", "AGDA2HS", "import", text s, "#-}" ]
  base = concat
    [ [ "Prelude (" ++ preludeImports ++ ")" ]
    , when pos
      [ "qualified Prelude" ]
    , case tokenText of
        TextToken       -> []
        StringToken     -> []
        ByteStringToken -> [ "qualified Data.ByteString.Char8 as BS" ]
    , [ "Data.Text" ]
    , [ "Data.String"]
    ]
  preludeImports = List.intercalate ", " ([ "Bool", "Char", "Double", "Integer", "String", "(.), Read, Ord, Eq, Show" ] ++ when pos
      [ "error" ])

-- * Bindings for the AST.

-- | Pretty-print types for token types similar to @Ident@.

prToken :: ModuleName -> TokenText -> String -> Bool -> Doc
prToken amod tokenText t pos = vsep
  [ if pos then vcat
      -- can't use prettyData as it excepts a Cat for the type
      [ hsep [ "data", text t, ":", "Set", "where" ]
      , nest 2 $ hsep
          [ text $ agdaLower t
          , ":"
          , pairT
          , parens intPairT
          , prettyCat typ
          , uArrow, text t
          ]
      ]
    else prettyData UnnamedArg t [(agdaLower t, [ typ ])]
  , pragmaData amod (StringType t tokenText) t t [(t, [])]
  ]
  where
  typ = case tokenText of
    TextToken       -> Cat "#String"
    ByteStringToken -> Cat "#String"
    StringToken     -> ListCat (Cat "Char")

-- | Pretty-print abstract syntax definition in Agda syntax.
--
--   We print this as one big mutual block rather than doing a
--   strongly-connected component analysis and topological
--   sort by dependency order.
--
absyn :: ModuleName -> Bool -> ConstructorStyle -> [Data] -> Doc
absyn _amod _havePos _style [] = empty
absyn  amod  havePos  style ds = vsep . ("mutual" :) . concatMap (map (nest 2) . prData amod havePos style) $ ds

-- | Pretty-print Agda data types and pragmas for AST.
--
-- >>> vsep $ prData "Foo" False UnnamedArg (Cat "Nat", [ ("Zero", []), ("Suc", [Cat "Nat"]) ])
-- data Nat : Set where
--   zero : Nat
--   suc  : Nat → Nat
-- <BLANKLINE>
-- {-# COMPILE GHC Nat = data Foo.Nat
--   ( Foo.Zero
--   | Foo.Suc
--   ) #-}
--
-- >>> vsep $ prData "Foo" True UnnamedArg (Cat "Nat", [ ("Zero", []), ("Suc", [Cat "Nat"]) ])
-- Nat = Nat' #BNFCPosition
-- <BLANKLINE>
-- data Nat' Pos# : Set where
--   zero : Pos# → Nat' Pos#
--   suc  : Pos# → Nat' Pos# → Nat' Pos#
-- <BLANKLINE>
-- {-# COMPILE GHC Nat' = data Foo.Nat'
--   ( Foo.Zero
--   | Foo.Suc
--   ) #-}
--
-- >>> vsep $ prData "Bar" False UnnamedArg (Cat "C", [ ("C1", []), ("C2", [Cat "C"]) ])
-- data C : Set where
--   c1 : C
--   c2 : C → C
-- <BLANKLINE>
-- {-# COMPILE GHC C = data Bar.C
--   ( Bar.C1
--   | Bar.C2
--   ) #-}
--
-- We return a list of 'Doc' rather than a single 'Doc' since want
-- to intersperse empty lines and indent it later.
-- If we intersperse the empty line(s) here to get a single 'Doc',
-- we will produce whitespace lines after applying 'nest'.
-- This is a bit of a design problem of the pretty print library:
-- there is no native concept of a blank line; @text ""@ is a bad hack.
--
prData :: ModuleName -> Bool -> ConstructorStyle -> Data -> [Doc]
prData amod True  style (Cat d, cs) = hsep [ text d, equals, text (sanitize primed), posT ] : prData' amod style DataData (addP d) primed cs'
  where
  -- Replace _ by - in Agda names to avoid illegal names like Foo_'.
  sanitize = replace '_' '-'
  primed   = d ++ "'"
  param    = "Pos#"
  addP c   = concat [sanitize c, "' ", param]
  cs'      = map (second $ \ cats -> Cat param : map addParam cats) cs
  addParam :: Cat -> Cat
  addParam = \case
    Cat c     -> Cat $ addP c
    ListCat c -> ListCat $ addParam c
    c         -> c

prData amod False style (Cat d, cs) = prData' amod style DataData d d cs
prData _    _     _     (c    , _ ) = error $ "prData: unexpected category " ++ prettyShow c

-- | Pretty-print Agda data types and pragmas.
--
-- >>> vsep $ prData' "ErrM" UnnamedArg "Err A" "Err_" [ ("Ok", [Cat "A"]), ("Bad", [ListCat $ Cat "Char"]) ]
-- data Err A : Set where
--   ok  : A → Err A
--   bad : #List Char → Err A
-- <BLANKLINE>
-- {-# COMPILE GHC Err = data ErrM.Err_
--   ( ErrM.Ok
--   | ErrM.Bad
--   ) #-}
--
prData' :: ModuleName -> ConstructorStyle -> PragmaInfo -> String -> String -> [(Fun, [Cat])] -> [Doc]
prData' amod style pragmaInfo d haskellDataName cs = 
  [ prettyData style d cs
  , pragmaData amod pragmaInfo (head $ words d) haskellDataName cs
  ]

-- | Pretty-print Agda binding for the BNFC Err monad.
--
-- Note: we use "Err" here since a category "Err" would also conflict
-- with BNFC's error monad in the Haskell backend.
prErrM :: ModuleName -> Doc
prErrM emod = vsep $ prData' emod UnnamedArg ErrData "Err A" "Err"
  [ ("Ok" , [Cat "A"])
  , ("Bad", [ListCat $ Cat "Char"])
  ]

-- | Pretty-print AST definition in Agda syntax.
--
-- >>> prettyData UnnamedArg "Nat" [ ("zero", []), ("suc", [Cat "Nat"]) ]
-- data Nat : Set where
--   zero : Nat
--   suc  : Nat → Nat
--
-- >>> prettyData UnnamedArg "C" [ ("C1", []), ("C2", [Cat "C"]) ]
-- data C : Set where
--   c1 : C
--   c2 : C → C
--
-- >>> :{
--   prettyData UnnamedArg "Stm"
--     [ ("block", [ListCat $ Cat "Stm"])
--     , ("while", [Cat "Exp", Cat "Stm"])
--     ]
-- :}
-- data Stm : Set where
--   block : #List Stm → Stm
--   while : Exp → Stm → Stm
--
-- >>> :{
--   prettyData NamedArg "Stm"
--     [ ("block", [ListCat $ Cat "Stm"])
--     , ("if", [Cat "Exp", Cat "Stm", Cat "Stm"])
--     ]
-- :}
-- data Stm : Set where
--   block : (ss : #List Stm) → Stm
--   if    : (e : Exp) (s₁ s₂ : Stm) → Stm
--
prettyData :: ConstructorStyle -> String -> [(Fun, [Cat])] -> Doc
prettyData style d cs = vcat (hsep [ "data", text d, colon, "Set", "where" ] :
                        mkTSTable (map (prettyConstructor style d) cs))

mkTSTable :: [(Doc,Doc)] -> [Doc]
mkTSTable = map (nest 2 . text) . table " : " . map mkRow
  where
  mkRow (c,t) = [ render c, render t ]

-- | Generate pragmas to bind Haskell AST to Agda.
--
-- >>> pragmaData "Foo" "Empty" "Bar" []
-- {-# COMPILE GHC Empty = data Foo.Bar () #-}
--
-- >>> pragmaData "Foo" "Nat" "Natty" [ ("zero", []), ("suc", [Cat "Nat"]) ]
-- {-# COMPILE GHC Nat = data Foo.Natty
--   ( Foo.zero
--   | Foo.suc
--   ) #-}
--
pragmaData :: ModuleName -> PragmaInfo -> String -> String -> [(Fun, [Cat])] -> Doc
pragmaData amod pragmaInfo d _ cs = case pragmaInfo of 
                                  ErrData  -> errP
                                  DataData -> pre
                                  StringType cat tokenText -> test cat tokenText
                                    --prettyList 2 (test cat tokenText) lparen (rparen <+> "#-}") "|" $
                                    --          map (prettyFun amod . fst) cs--test --pre
  --prettyList 2 pre lparen (rparen <+> "#-}") "|" $
  --  map (prettyFun amod . fst) cs
  where
  pre = hsep ["{-#", "COMPILE", "AGDA2HS", text d, "deriving", "(", "Eq," , "Show," , "Ord," , "Read" , ")" , "#-}"]
  errP = hsep ["{-#", "FOREIGN", "AGDA2HS", "type", text d, "= ErrM.Err #-}"]
  test cat tokenText = hsep [ "{-#", "FOREIGN", "AGDA2HS", "newtype", text cat, equals, genName (text cat) (text cat)
                            , text $ tokenTextType tokenText --, text $ concat [ amod, ".", haskellDataName ]
                            , " "
                            , "deriving", "(", "Eq," , "Show," , "Ord," , "Read," , "Data.String.IsString", ")"
                            , "#-}"
                            ]

-- | Pretty-print since rule as Agda constructor declaration.
--
-- >>> prettyConstructor UnnamedArg "D" ("c", [Cat "A", Cat "B", Cat "C"])
-- (c,A → B → C → D)
-- >>> prettyConstructor undefined  "D" ("c1", [])
-- (c1,D)
-- >>> prettyConstructor NamedArg "Stm" ("SIf", map Cat ["Exp", "Stm", "Stm"])
-- (sIf,(e : Exp) (s₁ s₂ : Stm) → Stm)
-- 
-- AGDA2HS requires uppercase naming of constructor, however since Agda cannot not overload a data type
-- this adds a ' to the constructor in case it has the same name as the data type.
prettyConstructor :: ConstructorStyle -> String -> (Fun,[Cat]) -> (Doc,Doc)
prettyConstructor style d (c, as) = if c == d then helper (c ++ "\'")  else helper c
    where
        helper c = (prettyCon c,) $ if null as then text d
        else hsep [ prettyConstructorArgs style as
                    , uArrow
                    , text d]

-- | Print the constructor argument telescope.
--
-- >>> prettyConstructorArgs UnnamedArg [Cat "A", Cat "B", Cat "C"]
-- A → B → C
--
-- >>> prettyConstructorArgs NamedArg (map Cat ["Exp", "Stm", "Stm"])
-- (e : Exp) (s₁ s₂ : Stm)
--
prettyConstructorArgs :: ConstructorStyle -> [Cat] -> Doc
prettyConstructorArgs style as =
  case style of
    UnnamedArg -> hsep $ List.intersperse uArrow ts
    NamedArg   -> hsep $ map (\ (x :| xs, t) -> parens (hsep [x, hsep xs, colon, t])) tel
  where
  ts  = map prettyCat as
  ns  = map (text . subscript) $ numberUniquely $ map nameSuggestion as
  tel = aggregateOn (render . snd) $ zip ns ts
  deltaSubscript = ord '₀' - ord '0' -- exploiting that '0' comes before '₀' in character table
  subscript (m, s) = maybe s (\ n -> s ++ map (chr . (deltaSubscript +) . ord) (show n)) m
  -- Aggregate consecutive arguments of the same type.
  aggregateOn :: Eq c => ((a,b) -> c) -> [(a,b)] -> [(List1 a,b)]
  aggregateOn f
    = map (\ p -> (List1.map fst p, snd (List1.head p)))
    . List1.groupBy ((==) `on` f)
    -- . List1.groupWith f -- Too recent, fails stack-7.8 install

-- | Suggest the name of a bound variable of the given category.
--
-- >>> map nameSuggestion [ ListCat (Cat "Stm"), TokenCat "Var", Cat "Exp" ]
-- ["ss","x","e"]
--
nameSuggestion :: Cat -> String
nameSuggestion = \case
  ListCat c     -> nameSuggestion c ++ "s"
  CoercCat d _  -> nameFor d
  Cat d         -> nameFor d
  TokenCat{}    -> "x"

-- | Suggest the name of a bound variable of the given base category.
--
-- >>> map nameFor ["Stm","ABC","#String"]
-- ["s","a","s"]
--
nameFor :: String -> String
nameFor d = [ toLower $ head $ dropWhile (== '#') d ]

-- | Number duplicate elements in a list consecutively, starting with 1.
--
-- >>> numberUniquely ["a", "b", "a", "a", "c", "b"]
-- [(Just 1,"a"),(Just 1,"b"),(Just 2,"a"),(Just 3,"a"),(Nothing,"c"),(Just 2,"b")]
--
numberUniquely :: forall a. Ord a => [a] -> [(Maybe Int, a)]
numberUniquely as = mapM step as `evalState` Map.empty
  where
  -- First pass: determine frequency of each element.
  counts :: Frequency a
  counts = foldl (flip incr) Map.empty as
  -- Second pass: consecutively number elements with frequency > 1.
  step :: a -> State (Frequency a) (Maybe Int, a)
  step a = do
    -- If the element has a unique occurrence, we do not need to number it.
    let n = Map.findWithDefault (error "numberUniquelyWith") a counts
    if n == 1 then return (Nothing, a) else do
      -- Otherwise, increase the counter for that element and number it
      -- with the new value.
      modify $ incr a
      gets ((,a) . Map.lookup a)

-- | A frequency map.
--
--   NB: this type synonym should be local to 'numberUniquely', but
--   Haskell lacks local type synonyms.
--   https://gitlab.haskell.org/ghc/ghc/issues/4020
type Frequency a = Map a Int

-- | Increase the frequency of the given key.
incr :: Ord a => a -> Frequency a -> Frequency a
incr = Map.alter $ maybe (Just 1) (Just . succ)

-- * Generate the defined constructors.

agdaDefCfg :: DefCfg
agdaDefCfg = DefCfg
  { sanitizeName = agdaLower
  , hasType      = ":"
  , arrow        = uArrow
  , lambda       = "λ"
  , cons         = "_∷_"
  , convTok      = agdaLower
  , convLitInt   = \ e -> App "#pos" dummyType [e]
  , polymorphism = (BaseT "{a : Set}" :)
  }

-- | Generate Haskell code for the @define@d constructors.
definedRules :: Bool -> CF -> Doc
definedRules havePos = vsep . definedRules' agdaDefCfg havePos

-- * Generate bindings for the pretty printers

-- UNUSED
-- -- | Generate Agda code to print tokens.
-- --
-- -- >>> printToken "Ident"
-- -- printIdent : Ident → #String
-- -- printIdent (ident s) = #stringFromList s
-- --
-- printToken :: String -> Doc
-- printToken t = vcat
--   [ hsep [ f, colon, text t, uArrow, stringT ]
--   , hsep [ f, lparen <> c <+> "s" <> rparen, equals, stringFromListT, "s" ]
--   ]
--   where
--   f = text $ "print" ++ t
--   c = text $ agdaLower t

-- | Generate Agda bindings to printers for AST.
--
-- >>> printers "Foo" $ map Cat [ "Exp", "Stm" ]
-- -- Binding the pretty printers.
-- <BLANKLINE>
-- postulate
--   printExp : Exp → #String
--   printStm : Stm → #String
-- <BLANKLINE>
-- {-# COMPILE GHC printExp = \ e -> Data.Text.pack (printTree (e :: Foo.Exp)) #-}
-- {-# COMPILE GHC printStm = \ s -> Data.Text.pack (printTree (s :: Foo.Stm)) #-}
--
-- Not sure these are needed in the AGDA2HS version.
printers :: ModuleName -> [Cat] -> Doc
printers _amod []   = empty
printers  amod cats = vsep
  [ "-- Binding the pretty printers."
  , vcat $ "postulate" : mkTSTable (map prettyTySig cats)
  , vcat $ map pragmaBind cats
  ]
  where
  prettyTySig c = (agdaPrinterName c, hsep [ prettyCat c, uArrow, stringT ])
  pragmaBind  c = hsep
    [ "{-#", "FOREIGN", "AGDA2HS", agdaPrinterName c, equals, "\\", y, "->"
    , "Data.Text.pack", parens ("printTree" <+> parens (y <+> "::" <+> t)), "#-}"
    ]
    where
    y = text $ nameSuggestion c
    t = catToType ((text amod <> text ".") <>) empty c  -- Removes CoercCat.

-- | Bind happy parsers.
--
-- >>> parsers StringToken Nothing [ListCat (CoercCat "Exp" 2)]
-- postulate
--   parseListExp2 : #String → Err (#List Exp)
-- <BLANKLINE>
-- {-# COMPILE GHC parseListExp2 = pListExp2 . myLexer . Data.Text.unpack #-}
--
-- >>> parsers TextToken Nothing [ListCat (CoercCat "Exp" 2)]
-- postulate
--   parseListExp2 : #String → Err (#List Exp)
-- <BLANKLINE>
-- {-# COMPILE GHC parseListExp2 = pListExp2 . myLexer #-}
--
parsers
  :: TokenText
  -> Maybe String  -- ^ Grammar uses layout?  If yes, Haskell layout module name.
  -> [Cat]         -- ^ Bind parsers for these non-terminals.
  -> Doc
parsers tokenText layoutMod cats =
  vcat ("postulate" : map (nest 2 . prettyTySig) cats)
  $++$
  vcat (map pragmaBind cats)
  where
  -- When grammar uses layout, we parametrize the parser by a boolean @tl@
  -- that indicates whether top layout should be used for this parser.
  -- Also, we add @resolveLayout tl@ to the pipeline after lexing.
  prettyTySig :: Cat -> Doc
  prettyTySig c = hsep . concat $
   [ [ agdaParserName c, colon ]
   , when layout [ boolT, uArrow ]
   , [ stringT, uArrow, "Err", prettyCatParens c ]
   ]
  pragmaBind :: Cat -> Doc
  pragmaBind c = hsep . concat $
    [ [ "{-#", "FOREIGN", "AGDA2HS", agdaParserName c, equals ]
    , when layout [ "\\", "tl", "->" ]
    , [ parserName c, "." ]
    , when layout [ hcat [ text lmod, ".", "resolveLayout" ], "tl", "." ]
    , [ "myLexer" ]
    , case tokenText of
        -- Agda's String is Haskell's Data.Text
        TextToken       -> []
        StringToken     -> [ ".", "Data.Text.unpack" ]
        ByteStringToken -> [ ".", "BS.pack", ".", "Data.Text.unpack" ]
    , [ "#-}" ]
    ]
  layout :: Bool
  layout = isJust layoutMod
  lmod :: String
  lmod = fromJust layoutMod

-- * Auxiliary functions

-- UNUSED
-- -- | Concatenate documents created from token categories,
-- --   separated by blank lines.
-- --
-- -- >>> allTokenCats text ["T", "U"]
-- -- T
-- -- <BLANKLINE>
-- -- U
-- allTokenCats :: (TokenCat -> Doc) -> [TokenCat] -> Doc
-- allTokenCats f = vsep . map f

-- | Pretty-print a rule name for Haskell.
prettyFun :: ModuleName -> Fun -> Doc
prettyFun amod c = text $ concat [ amod, ".", c ]

-- | Pretty-print a rule name for Agda.
prettyCon :: Fun -> Doc
prettyCon = text . agdaLower

-- | Turn identifier to non-capital identifier.
--   Needed, since in Agda a constructor cannot overload a data type
--   with the same name.
--
-- >>> map agdaLower ["SFun","foo","ABC","HelloWorld","module","Type_int","C1"]
-- ["sFun","foo","aBC","helloWorld","module'","type-int","c1"]
--
agdaLower :: String -> String
agdaLower = avoidKeywords . updateHead toUpper . replace '_' '-'
  -- WAS: replace '_' '\'' . BNFC.Utils.mkName agdaKeywords BNFC.Utils.MixedCase
  where
  updateHead _f []    = []
  updateHead f (x:xs) = f x : xs
  avoidKeywords s
    | s `Set.member` agdaKeywords = s ++ "\'"
    | otherwise = s

-- | A list of Agda keywords that would clash with generated names.
agdaKeywords :: Set String
agdaKeywords = Set.fromList $ words "abstract codata coinductive constructor data do eta-equality field forall hiding import in inductive infix infixl infixr instance let macro module mutual no-eta-equality open overlap pattern postulate primitive private public quote quoteContext quoteGoal quoteTerm record renaming rewrite Set syntax tactic unquote unquoteDecl unquoteDef using variable where with"


agda2hsConstr :: String -> String -> String
agda2hsConstr = undefined
-- | Name of Agda parser binding (mentions precedence).
--
-- >>> agdaParserName $ ListCat $ CoercCat "Exp" 2
-- parseListExp2
--
agdaParserName :: Cat -> Doc
agdaParserName c = text $ "parse" ++ identCat c

-- | Name of Agda printer binding (does not mention precedence).
--
-- >>> agdaPrinterName $ ListCat $ CoercCat "Exp" 2
-- printListExp
--
agdaPrinterName :: Cat -> Doc
agdaPrinterName c = text $ "print" ++ identCat (normCat c)

-- | Pretty-print a category as Agda type.
--   Ignores precedence.
--
-- >>> prettyCat $ ListCat (CoercCat "Exp" 2)
-- #List Exp
--
prettyCat :: Cat -> Doc
prettyCat = \case
  Cat s        -> text s
  TokenCat s   -> text s
  CoercCat s _ -> text s
  ListCat c    -> listT <+> prettyCatParens c

-- | Pretty-print category in parentheses, if 'compositeCat'.
prettyCatParens :: Cat -> Doc
prettyCatParens c = parensIf (compositeCat c) (prettyCat c)

-- | Is the Agda type corresponding to 'Cat' composite (or atomic)?
compositeCat :: Cat -> Bool
compositeCat = \case
  Cat c     -> any isSpace c
  ListCat{} -> True
  _         -> False


-- * Agda stub to test parser

-- | Write a simple IO library with fixed contents.
agdaLibContents
  :: String      -- ^ Name of Agda library module.
  -> Doc         -- ^ Contents of Agda library module.
agdaLibContents mod = vcat
  [ "-- Basic I/O library."
  , ""
  , "module" <+> text mod <+> "where"
  , ""
  , "open import Agda.Builtin.IO     public using (IO)"
  , "open import Agda.Builtin.List   public using (List; []; _∷_)"
  , "open import Agda.Builtin.String public using (String)"
  , "  renaming (primStringFromList to stringFromList)"
  , "open import Agda.Builtin.Unit   public using (⊤)"
  , ""
  , "-- I/O monad."
  , ""
  , "postulate"
  , "  return : ∀ {a} {A : Set a} → A → IO A"
  , "  _>>=_  : ∀ {a b} {A : Set a} {B : Set b} → IO A → (A → IO B) → IO B"
  , ""
  , "{-# COMPILE GHC return = \\ _ _ -> return    #-}"
  , "{-# COMPILE GHC _>>=_  = \\ _ _ _ _ -> (>>=) #-}"
  , ""
  , "infixl 1 _>>=_ _>>_"
  , ""
  , "_>>_  : ∀ {b} {B : Set b} → IO ⊤ → IO B → IO B"
  , "_>>_ = λ m m' → m >>= λ _ → m'"
  , ""
  , "-- Co-bind and functoriality."
  , ""
  , "infixr 1 _=<<_ _<$>_"
  , ""
  , "_=<<_  : ∀ {a b} {A : Set a} {B : Set b} → (A → IO B) → IO A → IO B"
  , "k =<< m = m >>= k"
  , ""
  , "_<$>_  : ∀ {a b} {A : Set a} {B : Set b} → (A → B) → IO A → IO B"
  , "f <$> m = do"
  , "  a ← m"
  , "  return (f a)"
  , ""
  , "-- Binding basic I/O functionality."
  , ""
  , "{-# FOREIGN GHC import qualified Data.Text #-}"
  , "{-# FOREIGN GHC import qualified Data.Text.IO #-}"
  , "{-# FOREIGN GHC import qualified System.Exit #-}"
  , "{-# FOREIGN GHC import qualified System.Environment #-}"
  , "{-# FOREIGN GHC import qualified System.IO #-}"
  , ""
  , "postulate"
  , "  exitFailure    : ∀{a} {A : Set a} → IO A"
  , "  getArgs        : IO (List String)"
  , "  putStrLn       : String → IO ⊤"
  , "  readFiniteFile : String → IO String"
  , ""
  , "{-# COMPILE GHC exitFailure    = \\ _ _ -> System.Exit.exitFailure #-}"
  , "{-# COMPILE GHC getArgs        = fmap (map Data.Text.pack) System.Environment.getArgs #-}"
  , "{-# COMPILE GHC putStrLn       = System.IO.putStrLn . Data.Text.unpack #-}"
  , "{-# COMPILE GHC readFiniteFile = Data.Text.IO.readFile . Data.Text.unpack #-}"
  ]

agdaMainContents
  :: String      -- ^ Name of Agda main module.
  -> String      -- ^ Name of Agda library module.
  -> String      -- ^ Name of Agda AST module.
  -> String      -- ^ Name of Agda parser module.
  -> Bool        -- ^ Is the grammar using layout?
  -> Cat         -- ^ Category to parse.
  -> Doc         -- ^ Contents of Agda main module.
agdaMainContents mod lmod amod pmod layout c = vcat
  [ "-- Test for Agda binding of parser.  Requires Agda >= 2.5.4."
  , ""
  , "module" <+> text mod <+> "where"
  , when layout "\nopen import Agda.Builtin.Bool using (true)"
  , "open import" <+> text lmod
  , "open import" <+> text amod 
  , "open import" <+> text pmod <+> "using" <+> parens ("Err;" <+> parser)
  , ""
  , "{-# FOREIGN AGDA2HS "
  , "{-# LANGUAGE OverloadedStrings #-}"
  , "import System.Environment ( getArgs )"
  , "import System.Exit        ( exitFailure )"
  , "import Control.Monad      ( when )"
  , "import Data.Text          ( pack )"
  , ""
  , "import" <+> text amod
  , "import" <+> (text $ (extractModName mod ++ "Lex   ( Token, mkPosToken )"))
  , "import" <+> (text $ (extractModName mod ++ "Par   ( pExp1, myLexer )"))
  , "import" <+> (text $ (extractModName mod ++ "Print ( Print, printTree )"))
  , "import" <+> (text $ (extractModName mod ++ "Skel  ()"))
  , ""
  , "type Err        = Either String"
  , "type ParseFun a = [Token] -> Err a"
  , "type Verbosity  = Int"
  , ""
  , "putStrV :: Verbosity -> String -> IO ()"
  , "putStrV v s = when (v > 1) $ putStrLn s"
  , ""
  , "runFile :: (Print a, Show a) => Verbosity -> ParseFun a -> FilePath -> IO ()"
  , "runFile v p f = putStrLn f >> readFile f >>= run v p"
  , ""
  , "run :: (Print a, Show a) => Verbosity -> ParseFun a -> String -> IO ()"
  , "run v p s ="
  , "  case p ts of"
  , "    Left err -> do"
  , "      putStrLn \"\\nParse              Failed...\\n\""
  , "      putStrV v \"Tokens:\""
  , "      mapM_ (putStrV v . showPosToken . mkPosToken) ts"
  , "      putStrLn err"
  , "      exitFailure"
  , "    Right tree -> do"
  , "      putStrLn \"\\nParse Successful!\""
  , "      showTree v tree"
  , "  where"
  , "  ts = myLexer $ pack s"
  , "  showPosToken ((l,c),t) = concat [ show l, \":\", show c, \"\\t\", show t ]"
  , ""
  , "showTree :: (Show a, Print a) => Int -> a -> IO ()"
  , "showTree v tree = do"
  , "  putStrV v $ \"\\n[Abstract Syntax]\\n\\n\" ++ show tree"
  , "  putStrV v $ \"\\n[Linearized tree]\\n\\n\" ++ printTree tree"
  , ""
  , "usage :: IO ()"
  , "usage = do"
  , "  putStrLn $ unlines"
  , "    [ \" usage: Call with one of the following argument combinations:\" "
  , "    , \"  (no arguments)  Parse stdin verbosely.\" "
  , "    , \"  (files)         Parse content of files verbosely.\" "
  , "    , \"  -s (files)      Silent mode. Parse content of files silently.\""
  , "    ]"
  , ""
  , "main :: IO ()"
  , "main = do"
  , "  args <- getArgs"
  , "  case args of"
  , "    [\"--help \"] -> usage"
  , "    []         -> getContents >>= run 2 pExp1"
  , "    \"-s\":fs    -> mapM_ (runFile 0 pExp1) fs"
  , "    fs         -> mapM_ (runFile 2 pExp1) fs"
  , ""


  , "#-}"
  ]
  where
  printer  = agdaPrinterName c
  parser   = agdaParserName c
  parseFun = hsep (parser : when layout ["true"])
    -- Permit use of top-level layout, if any.
