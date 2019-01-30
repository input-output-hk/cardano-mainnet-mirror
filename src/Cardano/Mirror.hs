module Cardano.Mirror
  ( mainnetEpochFiles
  )
where

import Data.List (sort)
import Paths_cardano_mainnet_mirror
import System.Directory
import System.FilePath


mainnetEpochFiles :: IO [FilePath]
mainnetEpochFiles = do
  dataDir <- getDataDir
  sort
    .   fmap (dataDir </>)
    .   filter ("epoch" `isExtensionOf`)
    <$> getDirectoryContents dataDir
