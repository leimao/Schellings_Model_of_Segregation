
module GridIO
(
    readInt,
    isStringInt,
    readGrid,
    countHome,
) where


import System.IO
import Text.Read (readMaybe)

import Grid


{- Read string to integer -}
readInt :: String -> Int 
readInt str = case readMaybe str :: Maybe(Int) of 
    Just num -> num 
    Nothing -> error $ "Could not read " ++ str ++ " as an Int!"

isStringInt :: String -> Bool
isStringInt str = case readMaybe str :: Maybe(Int) of 
    Just num -> True
    Nothing -> False


{- Read a line of string formatted integers to a list of integers -}
readIntLine :: String -> [Int]
readIntLine str = map readInt $ words str



stringToHome :: String -> [Home]
stringToHome str = map (charToHome) $ words str where
    charToHome substr 
        | substr == "R" = R
        | substr == "B" = B
        | substr == "O" = O
        | otherwise = error $ "Unrecognized Home element!"


stringToGrid :: String -> Grid Home
stringToGrid content = let
    contentLines = lines content
    headerLines = take 2 contentLines
    gridLines = drop 2 contentLines
    nr = readInt $ headerLines !! 0
    nc = readInt $ headerLines !! 1
    homeList = stringToHome $ foldl (\ accum line -> accum ++ " " ++ line) [] gridLines

    in Grid {nRows = nr, nCols = nc, grid = homeList}


readGrid :: String -> IO (Grid Home)
readGrid filepath = do
    content <- readFile filepath
    let gridLoaded = stringToGrid content
    return gridLoaded


countHome :: [Home] -> (Int, Int, Int)
countHome lst = foldl (counter) (0, 0, 0) lst where
    counter accum@(a, b, c) x
        | x == O = (a + 1, b, c)
        | x == R = (a, b + 1, c)
        | x == B = (a, b, c + 1)
