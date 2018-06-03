
module Grid
(
    Home(..),
    Grid(..),
    initializeGrid,
    initializeQueue,
    indexTo2DIndex,
    indicesTo2DIndicies,
) where 

data Home = B | R | O
    deriving (Eq, Show)

data Grid a = Grid {nRows :: Int, nCols :: Int, grid :: [a]}
    deriving (Eq, Show)

{- Initialize Grid Home -}
{- Input: nRows, nCols, percentageEmpty, percentageRed, percentageBlue -}
{- percentageRed + percentageBlue = 100 -}
initializeGrid :: Int -> Int -> Int -> Int -> Int -> Grid Home
initializeGrid height width percentageEmpty percentageRed percentageBlue = Grid {nRows = height, nCols = width, grid = (replicate nEmpty O) ++ (replicate nRed R) ++ (replicate nBlue B)} where
    nGrids = width * height
    nEmpty = percentageEmpty * nGrids `div` 100
    nOccupied = nGrids - nEmpty
    nRed = percentageRed * nOccupied `div` 100
    nBlue = nOccupied - nRed

{-
data Queue = Queue [(Int, Int)]
    deriving (Eq, Show)
-}

{- Get 1D indices for Empty Homes -}
getEmptyIndices :: [Home] -> [Int]
getEmptyIndices lst = foldl (\ accum x -> if snd x == O then accum ++ [fst x] else accum) [] $ zip [0 ..] lst

{- Transform 1D indices to 2D indices given nRows and nCols -}
indicesTo2DIndicies :: Int -> [Int] -> [(Int, Int)]
indicesTo2DIndicies width lst = map (indexTo2DIndex width) lst

indexTo2DIndex :: Int -> Int -> (Int, Int)
indexTo2DIndex width index = (index `div` width, index `mod` width)




{- Initialize open location queue -}

initializeQueue :: Grid Home -> [Int]
initializeQueue (Grid {nRows = height, nCols = width, grid = lst}) = getEmptyIndices lst

initialize2DQueue :: Grid Home -> [(Int, Int)]
initialize2DQueue (Grid {nRows = height, nCols = width, grid = lst}) = indicesTo2DIndicies height $ getEmptyIndices lst



testGrid1 = Grid {nRows = 4, nCols = 3, grid = [O, O, O, R, B, B, O, B, R, O, R, O]}
{-
[
[O, O, O, R]
[B, B, O, B]
[R, O, R, O]
]
-}
