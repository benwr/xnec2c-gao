module Utils where

import Control.Monad.State
import Data.Text (Text)
import Data.These
import Text.Pretty.Simple
import Types

hasFitness :: Phenotype -> Bool
hasFitness (Phenotype (This (PhenotypeData _ (Fitness {})))) = True
hasFitness (Phenotype (That bpm)) =
  any
    ( \(PhenotypeData _ f) -> case f of
        Fitness {} -> True
        _ -> False
    )
    bpm
hasFitness (Phenotype (These _ bpm)) =
  any
    ( \(PhenotypeData _ f) -> case f of
        Fitness {} -> True
        _ -> False
    )
    bpm
hasFitness _ = False

getFitness :: Phenotype -> Fitness
getFitness (Phenotype (This (PhenotypeData _ f@(Fitness {})))) = f
getFitness (Phenotype (This (PhenotypeData _ None))) = None
getFitness (Phenotype (That bmd)) = let f@(Fitness _ _ _) = foldr (<>) None $ fmap fitness bmd in f
getFitness (Phenotype (These _ bmd)) = let f@(Fitness _ _ _) = foldr (<>) None $ fmap fitness bmd in f

outputPhenotype :: Phenotype -> Text
outputPhenotype (Phenotype (This (PhenotypeData d _))) = d
outputPhenotype (Phenotype (These (PhenotypeData d _) _)) = d

score :: OptFun -> Phenotype -> Float
score (OF h) (Phenotype (This (PhenotypeData _ f@(Fitness {})))) = h f
score _ (Phenotype (This (PhenotypeData _ None))) = 0
score (OF h) (Phenotype (That bmd)) = case foldr (<>) None $ fmap fitness bmd of
  f@(Fitness {}) -> h f
  None -> 0
score (OF h) (Phenotype (These _ bmd)) = case foldr (<>) None $ fmap fitness bmd of
  f@(Fitness {}) -> h f
  None -> 0

ppState :: GAO ()
ppState = do
  s <- get
  pPrint s
