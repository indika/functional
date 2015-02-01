module Files where

import Control.Applicative

--import Data.Attoparsec
--import Text.ParserCombinators.Parsec

import Data.List(sort, sortBy)
import Data.Ord(comparing)


import System.IO(FilePath)
import System.Directory(getDirectoryContents, getModificationTime)
import System.FilePath.Posix(joinPath)

import Data.Time.Clock(UTCTime)
--import Data.Attoparsec(Parser, parseOnly)

import Parsing

data Pattern a = BasicPattern String | Parser a
--data Pattern = BasicPattern String


data Bob = Int | String



initialPath = "/Users/indika"
basicPattern = BasicPattern "cas"


main :: IO ()
main = do
    all_files <- getDirectoryContents initialPath
    mapM_ putStrLn (match basicPattern all_files)


--again = match basicPattern (getDirectoryContents initialPath)

-- No bind is required. just fmap
--theBind :: IO [FilePath] -> IO [UTCTime]


first :: FilePath -> IO [FilePath]
first root = getDirectoryContents root

-- Is this even possible [?]
--second :: IO [FilePath] -> IO [UTCTime]
--second xs = (>>=) xs (fmap getModificationTime)




-- If I were to use a glob like query, then I would
-- have to work on my parser module

-- match a set of files based on a pattern
match :: Pattern a -> [FilePath] -> [FilePath]
match (BasicPattern xs) = filter (startsWith xs)
--match (Parser a) = filter (parseOnly a)

startsWith :: Eq a => [a] -> [a] -> Bool
startsWith [] _ = True
startsWith _ [] = False
startsWith a b = and $ zipWith (==) a b


-- Finds files and returns the absolute path
find :: FilePath -> Pattern a -> IO [FilePath]
find initialPath pattern = fmap (map (\x -> joinPath [initialPath, x])) matches
    where matches = fmap (match pattern) (getDirectoryContents initialPath)

findSorted :: FilePath -> Pattern a -> IO [FilePath]
findSorted initialPath pattern = sortDescending <$> find initialPath pattern

sortAscending :: [FilePath] -> [FilePath]
sortAscending = sort

sortDescending :: [FilePath] -> [FilePath]
sortDescending = sortBy (flip compare)


-- This takes an AbsoluteFilePath
-- Should I create a new type?

-- This involves two IO operations
-- I need to sequence two IO operations
-- But is it really dependant on the outcome of the first
-- because it is just going to be a map

--lastModified :: [FilePath] -> IO [FilePath]
--lastModified fs =


aFile = "/Users/indika/users.py"

doSomething :: FilePath -> IO UTCTime
doSomething fp = getModificationTime fp


--g :: [FilePath] -> IO [FilePath]
--g fs = fmap (sortBy compare) modified_fs
--    where modified_fs = map getModificationTime fs -- IO UTCTime


-- I have two UTCTimes in an IO Context
--
compareTuples :: (FilePath, IO UTCTime) -> (FilePath, IO UTCTime) -> IO Ordering
compareTuples (_, x) (_, y) = pure compare <*> x <*> y

-- I have to do the sort without the IO Context
compareFiles :: (FilePath, UTCTime) -> (FilePath, UTCTime) -> Ordering
compareFiles (_, x) (_, y) = compare x y

compare' :: (String, Int) -> (String, Int) -> Ordering
compare' (_, x) (_, y) = compare x y



tuples = [("bob", 400), ("jane", 6), ("namehunt", 23)]
--doIt = sortBy compare' tuples

--withContext tuples = pure sortBy <*> (compareTuples tuples)




--something :: FilePath -> (FilePath,  UTCTime)
--something fp = (fp, getModificationTime fp)

aPath = "/Users/indika/temp"

getFiles :: FilePath -> IO [FilePath]
getFiles startPath = getDirectoryContents startPath


mapper :: [FilePath] -> [ IO UTCTime ]
mapper fs = fmap getModificationTime fs

something :: FilePath -> IO [IO UTCTime]
something path = fmap mapper (getFiles path)


-- but, I cannot evaluate this
sequenceIt bob = fmap sequence bob


getModificationTime' :: FilePath ->  IO(FilePath, UTCTime)
getModificationTime' fp = fmap (\x -> (fp, x)) (getModificationTime fp)


sortIt :: [(FilePath, UTCTime)] -> [(FilePath, UTCTime)]
sortIt xs = sortBy (comparing snd) xs

doIt = (find aPath basicPattern) >>= (\x -> sequence (fmap getModificationTime' x))

final = fmap sortIt doIt

--main :: IO ()
--main = doIt








