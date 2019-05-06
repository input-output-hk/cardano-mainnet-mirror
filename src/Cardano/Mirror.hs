module Cardano.Mirror
  ( mainnetEpochFiles
  )
where

import Data.List (sort)
import Paths_cardano_mainnet_mirror (getDataDir)
import System.Directory (doesDirectoryExist, getDirectoryContents)
import System.Environment (lookupEnv)
import System.Exit (exitFailure)
import System.FilePath ((</>), isExtensionOf)

-- Failing here (with 'exitFailure') is fine because this function is only ever
-- used to test maiinnet validaton. It is never used in production code.

mainnetEpochFiles :: IO [FilePath]
mainnetEpochFiles =
  -- Lookup the environment variable first and if that fails, use the one
  -- provided by cabal (using 'Paths_cardano_mainnet_mirror').
  lookupEnv "CARDANO_MAINNET_MIRROR"
    >>= maybe getDataDir pure
    >>= \ fpath -> do
      exists <- doesDirectoryExist fpath
      if exists
        then sort
              . fmap (fpath </>)
              . filter ("epoch" `isExtensionOf`)
              <$> getDirectoryContents fpath
        else do
          putStrLn $ "mainnetEpochFiles: directory '" ++ fpath ++ "' does not exist."
          exitFailure
