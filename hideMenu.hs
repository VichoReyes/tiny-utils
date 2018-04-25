import Control.Monad (when, forM_)
import Control.Exception (catch)
import System.Directory (doesFileExist) -- copyFile?
import System.FilePath.Posix ((</>))
import System.Environment (getArgs, getEnv)
import System.Exit (die)

systemLevelDir = "/usr/share/applications/"
userLevelDir = ".local/share/applications/"
lineToAppend = "NoDisplay=true"

absoluteNewPaths :: String -> [String] -> IO [String]
absoluteNewPaths relative fileNames = do
    home <- getEnv "HOME"
    return $ map ((home </> relative) </>) fileNames

main = do
    fileNames <- getArgs
    when (length fileNames == 0) $
        die "Error: No files provided"
    let paths = (systemLevelDir </>) <$> fileNames
    allValidPaths <- and <$> traverse doesFileExist paths
    when (not allValidPaths) $
        die "Error: One or more files didn't exist"
    files <- fmap lines <$> mapM readFile paths
    let allValidXdg = all ("[Desktop Entry]" `elem`) files
    when (not allValidXdg) $
        die "Error: One or more files didn't have a [Desktop Entry] line"
    targets <- absoluteNewPaths userLevelDir fileNames
    let conjoined = zip targets $ map dontDisplay files
    forM_ conjoined $ uncurry writeFile

dontDisplay :: [String] -> String
dontDisplay desktopFile = unlines $ start ++ lineToAppend:rest
    where (start', rest') = span (/= "[Desktop Entry]") desktopFile
          start = start' ++ [head rest']
          rest = tail rest'
