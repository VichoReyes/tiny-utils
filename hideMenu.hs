import Control.Monad (when, forM_)
import Control.Exception (catch)
import System.Directory (doesFileExist) -- copyFile?
import System.FilePath.Posix ((</>), takeFileName)
import System.Environment (getArgs, getEnv)
import System.Exit (die)
import Data.List (isPrefixOf)


systemLevelDir = "/usr/share/applications/"
userLevelDir = ".local/share/applications/"
lineToAppend = "NoDisplay=true"


getNewPaths :: String -> [String] -> IO [String]
getNewPaths relative fileNames = do
  home <- getEnv "HOME"
  return $ map ((home </> relative) </>) fileNames


getOldPaths :: IO [String]
getOldPaths = do
  args <- getArgs
  case args of
    [] -> lines <$> getContents
    ["--"] -> lines <$> getContents
    _ | systemLevelDir `isPrefixOf` (head args) -> return args
      | otherwise -> return $ map (systemLevelDir </>) args


copyOneFile :: String -> IO ()
copyOneFile absoluteOldPath = do
  newContents <- dontDisplay . lines <$> readFile absoluteOldPath
  newPath <- getNewPath
  writeFile newPath newContents
    where getNewPath = do
            home <- getEnv "HOME"
            return $ home </> userLevelDir </> fileName
          fileName = takeFileName absoluteOldPath


main = do
  absoluteOldPaths <- getOldPaths
  allValidPaths <- and <$> traverse doesFileExist absoluteOldPaths
  when (not allValidPaths) $
      die "Error: One or more files didn't exist"
  traverse copyOneFile absoluteOldPaths


dontDisplay :: [String] -> String
dontDisplay desktopFile = unlines $ start ++ lineToAppend:rest
    where (start', rest') = span (/= "[Desktop Entry]") desktopFile
          start = start' ++ [head rest']
          rest = tail rest'
