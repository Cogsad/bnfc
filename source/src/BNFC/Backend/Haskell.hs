{-
    BNF Converter: Haskell main file
    Copyright (C) 2004  Author:  Markus Forsberg, Peter Gammie, Aarne Ranta

-}

{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}

module BNFC.Backend.Haskell (makeHaskell, AlexVersion(..), makefile, testfile) where

import qualified Control.Monad as Ctrl
import Data.Maybe      (isJust)
import System.FilePath ((<.>), (</>), pathSeparator)
import Text.Printf     (printf)
import Text.PrettyPrint

import BNFC.Backend.Agda
import BNFC.Backend.Agda2HS

import BNFC.Backend.Base
import BNFC.Backend.Haskell.CFtoHappy
import BNFC.Backend.Haskell.CFtoAlex3
import BNFC.Backend.Haskell.CFtoAbstract
import BNFC.Backend.Haskell.CFtoTemplate
import BNFC.Backend.Haskell.CFtoPrinter
import BNFC.Backend.Haskell.CFtoLayout
import BNFC.Backend.Haskell.HsOpts
import BNFC.Backend.Haskell.MkErrM
import BNFC.Backend.Haskell.Utils
import BNFC.Backend.Txt2Tag
import BNFC.Backend.XML (makeXML)
import qualified BNFC.Backend.Common.Makefile as Makefile

import BNFC.CF
import BNFC.Options
  ( SharedOptions(..), TokenText(..), AlexVersion(..), HappyMode(..)
  , isDefault, printOptions
  )
import BNFC.Utils (when, table, getZonedTimeTruncatedToSeconds)


-- | Entrypoint for the Haskell backend.
makeHaskell :: SharedOptions -> CF -> Backend
makeHaskell opts cf = if agda2hs opts then makeHaskell'' opts cf else makeHaskell' opts cf

makeHaskell' :: SharedOptions -> CF -> Backend
makeHaskell' opts cf = do
  -- Get current time in printable form.
  time <- liftIO $ show <$> getZonedTimeTruncatedToSeconds

  let absMod = absFileM opts
      lexMod = alexFileM opts
      parMod = happyFileM opts
      prMod  = printerFileM opts
      layMod = layoutFileM opts
      errMod = errFileM opts
  do
    -- Generate abstract syntax and pretty printer.
    mkfile (absFile opts) comment $ cf2Abstract opts absMod cf
    mkfile (printerFile opts) comment $ cf2Printer (tokenText opts) (functor opts) False prMod absMod cf

    -- Generate Alex lexer.  Layout is resolved after lexing.
    case alexMode opts of
      Alex3 -> do
        mkfile (alexFile opts) commentWithEmacsModeHint $ cf2alex3 lexMod (tokenText opts) cf
        liftIO $ printf "Use Alex 3 to compile %s.\n" (alexFile opts)

    Ctrl.when (hasLayout cf) $ mkfile (layoutFile opts) comment $
      cf2Layout layMod lexMod cf

    -- Generate Happy parser and matching test program.
    do
      mkfile (happyFile opts) commentWithEmacsModeHint $
        cf2Happy parMod absMod lexMod (glr opts) (tokenText opts) (functor opts) cf
      -- liftIO $ printf "%s Tested with Happy 1.15\n" (happyFile opts)
      mkfile (tFile opts) comment $ testfile opts cf

    -- Both Happy parser and skeleton (template) rely on Err.
    mkfile (errFile opts) comment $ mkErrM errMod
    mkfile (templateFile opts) comment $ cf2Template (templateFileM opts) absMod (functor opts) cf

    -- Generate txt2tags documentation.
    mkfile (txtFile opts) t2tComment $ cfToTxt (lang opts) cf

    -- Generate XML and DTD printers.
    case xml opts of
      2 -> makeXML opts True cf
      1 -> makeXML opts False cf
      _ -> return ()

    -- Generate Agda bindings for AST, Printer and Parser.
    Ctrl.when (agda opts) $ makeAgda time opts cf

    -- Generate Makefile.
    Makefile.mkMakefile (optMake opts) $ makefile opts cf

makeHaskell'' :: SharedOptions -> CF -> Backend
makeHaskell'' opts cf = do 

    -- Get current time in printable form.
    time <- liftIO $ show <$> getZonedTimeTruncatedToSeconds
    let absMod = absFileM opts
        lexMod = alexFileM opts
        parMod = happyFileM opts
        prMod  = printerFileM opts
        layMod = layoutFileM opts
        errMod = errFileM opts

    -- Printfile
    mkfile (printerFile opts) comment $ cf2Printer (tokenText opts) (functor opts) False prMod absMod cf 
        -- Generate Alex lexer.  Layout is resolved after lexing.
    case alexMode opts of
      Alex3 -> do
        mkfile (alexFile opts) commentWithEmacsModeHint $ cf2alex3 lexMod (tokenText opts) cf
        liftIO $ printf "Use Alex 3 to compile %s.\n" (alexFile opts)
        
    Ctrl.when (hasLayout cf) $ mkfile (layoutFile opts) comment $
      cf2Layout layMod lexMod cf
    do
      mkfile (happyFile opts) commentWithEmacsModeHint $
        cf2Happy parMod absMod lexMod (glr opts) (tokenText opts) (functor opts) cf
      -- liftIO $ printf "%s Tested with Happy 1.15\n" (happyFile opts)
      mkfile (tFile opts) comment $ testfile opts cf

    -- Both Happy parser and skeleton (template) rely on Err.
    mkfile (errFile opts) comment $ mkErrM errMod
    mkfile (templateFile opts) comment $ cf2Template (templateFileM opts) absMod (functor opts) cf

    -- Generate txt2tags documentation.
    mkfile (txtFile opts) t2tComment $ cfToTxt (lang opts) cf

    -- Generate XML and DTD printers.
    case xml opts of
      2 -> makeXML opts True cf
      1 -> makeXML opts False cf
      _ -> return ()

    -- Generate Agda2hs files
    makeAgda2HS time opts cf

    Makefile.mkMakefile opts $ makefile opts cf

-- | Generate the makefile (old version, with just one "all" target).
_oldMakefile
  :: Options
  -> String    -- ^ Filename of the makefile.
  -> Doc       -- ^ Content of the makefile.
_oldMakefile opts makeFile = vcat
  [ Makefile.mkRule "all" [] $ concat $
      [ [ unwords $ [ "happy -gca" ] ++ glrParams ++ [ happyFile opts ] ]
      , [ "alex -g " ++ alexFile opts ]
      ]
  , cleanRule opts
  , distCleanRule opts makeFile
  ]
  where
  glrParams :: [String]
  glrParams = when (glr opts == GLR) $ [ "--glr", "--decode" ]

-- | Rule to clean GHC and Latex generated files.
cleanRule :: Options -> Doc
cleanRule opts = Makefile.mkRule "clean" [] $ concat $
  [ [ rmGen ]
  , when (agda opts) rmAgda
  ]
  where
  rmGen  = unwords $ [ "-rm", "-f" ] ++ map prefix gen
  gen    = concat [ genHs, genLtx, genAg ]
  genHs  = [ "*.hi", "*.o" ]
  genLtx = [ "*.log", "*.aux", "*.dvi" ]
  genAg  = when (agda opts) $ [ "*.agdai" ]
  rmAgda = [ "-rm -rf MAlonzo" ]
  prefix = if null dir then id else (dir </>)
  dir    = codeDir opts

-- | Rule to clean all files generated by BNFC and the subsequent tools.
distCleanRule :: Options -> String -> Doc
distCleanRule opts makeFile = Makefile.mkRule "distclean" ["clean"] $
  [ unwords . concat $
    [ [ "-rm -f" ]
      -- Generated files that have a .bak variant
    , concatMap (\ f -> alsoBak (f opts))
      [ absFile        -- Abs.hs
      , composOpFile   -- ComposOp.hs
      , txtFile        -- Doc.txt
      , errFile        -- ErrM.hs
      , layoutFile     -- Layout.hs
      , alexFile       -- Lex.x
      , happyFile      -- Par.y
      , printerFile    -- Print.hs
      , templateFile   -- Skel.hs
      , tFile          -- Test.hs
      , xmlFile        -- XML.hs
      , agdaASTFile    -- AST.agda
      , agdaParserFile -- Parser.agda
      , agdaLibFile    -- IOLib.agda
      , agdaMainFile   -- Main.agda
      , (\ opts -> dir ++ lang opts ++ ".dtd")
      ]
      -- Files that have no .bak variant
    , map (\ (file, ext) -> mkFile withLang file ext opts)
      [ ("Test"    , "")
      , ("Lex"     , "hs")
      , ("Par"     , "hs")
      , ("Par"     , "info")
      , ("ParData" , "hs")  -- only if --glr
      ]
    , [ "Main" | agda opts ]
    , [ makeFile ]
    ]
  , if null dir then "" else "-rmdir -p " ++ dir
  ]
  where
  dir = let d = codeDir opts in if null d then "" else d ++ [pathSeparator]

  alsoBak :: FilePath -> [FilePath]
  alsoBak s = [ s, s <.> "bak" ]

makefileHeader :: Options -> Doc
makefileHeader Options{ agda, glr } = vcat
  [ "# Makefile for building the parser and test program."
  , ""
  , when agda $
    "AGDA       = agda"
  , "GHC        = ghc"
  , "HAPPY      = happy"
  , hsep $ concat
    [ [ "HAPPY_OPTS = --array --info" ]
    , if glr == GLR
      then [ "--glr --decode" ]
      else [ "--ghc --coerce" ]
        -- These options currently (2021-02-14) do not work with GLR mode
        -- see https://github.com/simonmar/happy/issues/173
    ]
  , "ALEX       = alex"
  , "ALEX_OPTS  = --ghc"
  , ""
  ]


-- | Generate the makefile.
makefile
  :: Options
  -> CF
  -> String    -- ^ Filename of the makefile.
  -> Doc       -- ^ Content of the makefile.
makefile opts cf makeFile = vcat
  [ makefileHeader opts
  , phonyRule
  , defaultRule
  , vcat [ "# Rules for building the parser." , "" ]
  -- If option -o was given, we have no access to the grammar file
  -- from the Makefile.  Thus, we have to drop the rule for
  -- reinvokation of bnfc.
  , when (isDefault outDir opts) $ bnfcRule
  , happyRule
  , alexRule
  , testParserRule
  , when (agda opts) $ agdaRule
  , vcat [ "# Rules for cleaning generated files." , "" ]
  , cleanRule opts
  , distCleanRule opts makeFile
  , "# EOF"
  ]
  where
  -- | List non-file targets here.
  phonyRule :: Doc
  phonyRule = vcat
    [ "# List of goals not corresponding to file names."
    , ""
    , Makefile.mkRule ".PHONY" [ "all", "clean", "distclean" ] []
    ]
  -- | Default: build test parser(s).
  defaultRule :: Doc
  defaultRule = vcat
     [ "# Default goal."
     , ""
     , Makefile.mkRule "all" tgts []
     ]
     where
     tgts = concat $
              [ [ tFileExe opts ]
              , [ "Main" | agda opts ]
              ]

  -- | Rule to reinvoke @bnfc@ to updated parser.
  --   Reinvokation should not recreate @Makefile@!
  bnfcRule :: Doc
  bnfcRule = Makefile.mkRule tgts [ lbnfFile opts ] [ recipe ]
    where
    recipe    = unwords [ "bnfc", printOptions opts{ optMake = Nothing } ]
    tgts      = unwords . map ($ opts) . concat $
      [ [ absFile ]
      , [ layoutFile | lay ]
      , [ alexFile, happyFile, printerFile, tFile ]
      , when (agda opts)
        [ agdaASTFile, agdaParserFile, agdaLibFile, agdaMainFile ]
      ]

  lay :: Bool
  lay = hasLayout cf

  -- | Rule to invoke @happy@.
  happyRule :: Doc
  happyRule = Makefile.mkRule "%.hs" [ "%.y" ] [ "${HAPPY} ${HAPPY_OPTS} $<" ]

  -- | Rule to invoke @alex@.
  alexRule :: Doc
  alexRule = Makefile.mkRule "%.hs" [ "%.x" ] [ "${ALEX} ${ALEX_OPTS} $<" ]

  -- | Rule to build Haskell test parser.
  testParserRule :: Doc
  testParserRule = Makefile.mkRule tgt deps [ "${GHC} ${GHC_OPTS} $@" ]
    where
    tgt :: String
    tgt = tFileExe opts
    deps :: [String]
    deps = map ($ opts) $ concat
      [ [ absFile ]
      , [ layoutFile | lay ]
      , [ alexFileHs
        , happyFileHs
        , printerFile
        , tFile
        ]
      ]

  -- | Rule to build Agda parser.
  agdaRule :: Doc
  agdaRule = Makefile.mkRule "Main" deps [ "${AGDA} --no-libraries --ghc --ghc-flag=-Wwarn $<" ]
    where
    deps = map ($ opts) $ concat
      [ [ agdaMainFile  -- must be first!
        , agdaASTFile
        , agdaParserFile
        , agdaLibFile
        -- Haskell modules bound by Agda modules:
        , errFile
        ]
      , [ layoutFile | lay ]
      , [ alexFileHs
        , happyFileHs
        , printerFile
        ]
      ]

testfile :: Options -> CF -> String
testfile opts cf = unlines $ concat $
  [ [ "-- | Program to test parser."
    , ""
    , "module Main where"
    , ""
    , "import Prelude"
    , "  ( ($), (.)"
    ]
  , [ "  , Bool(..)" | lay ]
  , [ "  , Either(..)"
    , "  , Int, (>)"
    , "  , String, (++), concat, unlines"
    , "  , Show, show"
    , "  , IO, (>>), (>>=), mapM_, putStrLn"
    , "  , FilePath"
    ]
  , [ "  , getContents, readFile" | tokenText opts == StringToken ]
  , [ "  , error, flip, map, replicate, sequence_, zip" | use_glr ]
  , [ "  )" ]
  , case tokenText opts of
      StringToken -> []
      TextToken ->
        [ "import Data.Text.IO   ( getContents, readFile )"
        , "import qualified Data.Text"
        ]
      ByteStringToken ->
        [ "import Data.ByteString.Char8 ( getContents, readFile )"
        , "import qualified Data.ByteString.Char8 as BS"
        ]
  , [ "import System.Environment ( getArgs )"
    , "import System.Exit        ( exitFailure )"
    , "import Control.Monad      ( when )"
    , ""
    ]
  , table "" $ concat
    [ [ [ "import " , absFileM      opts , " (" ++ if_glr impTopCat ++ ")" ] ]
    , [ [ "import " , layoutFileM   opts , " ( resolveLayout )"      ] | lay     ]
    , [ [ "import " , alexFileM     opts , " ( Token, mkPosToken )"              ]
      , [ "import " , happyFileM    opts , " ( " ++ impParser ++ ", myLexer" ++ impParGLR ++ " )" ]
      , [ "import " , printerFileM  opts , " ( Print, printTree )"               ]
      , [ "import " , templateFileM opts , " ()"                                 ]
      ]
    , [ [ "import " , xmlFileM      opts , " ( XPrint, printXML )"   ] | use_xml ]
    ]
  , [ "import qualified Data.Map ( Map, lookup, toList )" | use_glr ]
  , [ "import Data.Maybe ( fromJust )"                    | use_glr ]
  , [ ""
    , "type Err        = Either String"
    , if use_glr
      then "type ParseFun a = [[Token]] -> (GLRResult, GLR_Output (Err a))"
      else "type ParseFun a = [Token] -> Err a"
    , "type Verbosity  = Int"
    , ""
    , "putStrV :: Verbosity -> String -> IO ()"
    , "putStrV v s = when (v > 1) $ putStrLn s"
    , ""
    , "runFile :: (" ++ xpr ++ if_glr "TreeDecode a, " ++ "Print a, Show a) => Verbosity -> ParseFun a -> FilePath -> IO ()"
    , "runFile v p f = putStrLn f >> readFile f >>= run v p"
    , ""
    , "run :: (" ++ xpr ++ if_glr "TreeDecode a, " ++ "Print a, Show a) => Verbosity -> ParseFun a -> " ++ tokenTextType (tokenText opts) ++ " -> IO ()"
    , (if use_glr then runGlr else runStd use_xml) myLLexer
    , "showTree :: (Show a, Print a) => Int -> a -> IO ()"
    , "showTree v tree = do"
    , "  putStrV v $ \"\\n[Abstract Syntax]\\n\\n\" ++ show tree"
    , "  putStrV v $ \"\\n[Linearized tree]\\n\\n\" ++ printTree tree"
    , ""
    , "usage :: IO ()"
    , "usage = do"
    , "  putStrLn $ unlines"
    , "    [ \"usage: Call with one of the following argument combinations:\""
    , "    , \"  --help          Display this help message.\""
    , "    , \"  (no arguments)  Parse stdin verbosely.\""
    , "    , \"  (files)         Parse content of files verbosely.\""
    , "    , \"  -s (files)      Silent mode. Parse content of files silently.\""
    , "    ]"
    , ""
    , "main :: IO ()"
    , "main = do"
    , "  args <- getArgs"
    , "  case args of"
    , "    [\"--help\"] -> usage"
    , "    []         -> getContents >>= run 2 " ++ firstParser
    , "    \"-s\":fs    -> mapM_ (runFile 0 " ++ firstParser ++ ") fs"
    , "    fs         -> mapM_ (runFile 2 " ++ firstParser ++ ") fs"
    , ""
    ]
  , if_glr $
    [ "the_parser :: ParseFun " ++ catToStr topType
    , "the_parser = lift_parser " ++ render (parserName topType)
    , ""
    , liftParser
    ]
  ]
  where
    lay         = isJust hasTopLevelLayout || not (null layoutKeywords)
    use_xml     = xml opts > 0
    xpr         = if use_xml then "XPrint a, "     else ""
    use_glr     = glr opts == GLR
    if_glr      :: Monoid a => a -> a
    if_glr      = when use_glr
    firstParser = if use_glr then "the_parser" else impParser
    impParser   = render (parserName topType)
    topType     = firstEntry cf
    impTopCat   = unwords [ "", identCat topType, "" ]
    impParGLR   = if_glr ", GLRResult(..), Branch, ForestId, TreeDecode(..), decode"
    myLLexer atom
      | lay     = unwords [ "resolveLayout", show useTopLevelLayout, "$ myLexer", atom]
      | True    = unwords [ "myLexer", atom]
    (hasTopLevelLayout, layoutKeywords, _) = layoutPragmas cf
    useTopLevelLayout = isJust hasTopLevelLayout

runStd :: Bool -> (String -> String) -> String
runStd xml myLLexer = unlines $ concat
 [ [ "run v p s ="
   , "  case p ts of"
   , "    Left err -> do"
   , "      putStrLn \"\\nParse              Failed...\\n\""
   , "      putStrV v \"Tokens:\""
   , "      mapM_ (putStrV v . showPosToken . mkPosToken) ts"
   -- , "      putStrV v $ show ts"
   , "      putStrLn err"
   , "      exitFailure"
   , "    Right tree -> do"
   , "      putStrLn \"\\nParse Successful!\""
   , "      showTree v tree"
   ]
 , [ "      putStrV v $ \"\\n[XML]\\n\\n\" ++ printXML tree" | xml ]
 , [ "  where"
   , "  ts = " ++ myLLexer "s"
   , "  showPosToken ((l,c),t) = concat [ show l, \":\", show c, \"\\t\", show t ]"
   ]
 ]

runGlr :: (String -> String) -> String
runGlr myLLexer
 = unlines
   [ "run v p s"
   , " = let ts = map (:[]) $ " ++ myLLexer "s"
   , "       (raw_output, simple_output) = p ts in"
   , "   case simple_output of"
   , "     GLR_Fail major minor -> do"
   , "                               putStrLn major"
   , "                               putStrV v minor"
   , "     GLR_Result df trees  -> do"
   , "                               putStrLn \"\\nParse Successful!\""
   , "                               case trees of"
   , "                                 []        -> error \"No results but parse succeeded?\""
   , "                                 [Right x] -> showTree v x"
   , "                                 xs@(_:_)  -> showSeveralTrees v xs"
   , "   where"
   , "  showSeveralTrees :: (Print b, Show b) => Int -> [Err b] -> IO ()"
   , "  showSeveralTrees v trees"
   , "   = sequence_ "
   , "     [ do putStrV v (replicate 40 '-')"
   , "          putStrV v $ \"Parse number: \" ++ show n"
   , "          showTree v t"
   , "     | (Right t,n) <- zip trees [1..]"
   , "     ]"
   ]

liftParser :: String
liftParser
 = unlines
   [ "type Forest = Data.Map.Map ForestId [Branch]      -- omitted in ParX export."
   , "data GLR_Output a"
   , " = GLR_Result { pruned_decode     :: (Forest -> Forest) -> [a]"
   , "              , semantic_result   :: [a]"
   , "              }"
   , " | GLR_Fail   { main_message :: String"
   , "              , extra_info   :: String"
   , "              }"
   , ""
   , "lift_parser"
   , " :: (TreeDecode a, Show a, Print a)"
   , " => ([[Token]] -> GLRResult) -> ParseFun a"
   , "lift_parser parser ts"
   , " = let result = parser ts in"
   , "   (\\o -> (result, o)) $"
   , "   case result of"
   , "     ParseError ts f -> GLR_Fail \"Parse failed, unexpected token(s)\\n\""
   , "                                 (\"Tokens: \" ++ show ts)"
   , "     ParseEOF   f    -> GLR_Fail \"Parse failed, unexpected EOF\\n\""
   , "                                 (\"Partial forest:\\n\""
   , "                                    ++ unlines (map show $ Data.Map.toList f))"
   , "     ParseOK r f     -> let find   f = fromJust . ((flip Data.Map.lookup) f)"
   , "                            dec_fn f = decode (find f) r"
   , "                        in GLR_Result (\\ff -> dec_fn $ ff f) (dec_fn f)"
   ]
