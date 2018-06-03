
module Simulation
(
    relocate,
    relocateAll,
    satisfactionRate,
) where 


import Grid
import Data.List
import Data.Maybe

{- Remove invalid indices in 2D index list -}
filterInvalidIndices :: Int -> Int -> [(Int, Int)] -> [(Int, Int)]
filterInvalidIndices height width lst = filter (\ x -> fst x >= 0 && fst x < height && snd x >= 0 && snd x < width) lst

filterIndices :: (Int, Int) -> [(Int, Int)] -> [(Int, Int)]
filterIndices index lst = filter (\ x -> x == index) lst

{- Find R-neighborhood using 2D indices -}
find2DNeighbor :: Int -> Int -> Int -> (Int, Int) -> [(Int, Int)]
find2DNeighbor height width r (x, y) = filterInvalidIndices height width $ [(i, j) | i <- [x - r .. x + r], j <- [y - r .. y + r]]

{- Find R-neighborhood using 1D indices -}
findNeighbor :: Int -> Int -> Int -> Int -> [Int]
findNeighbor height width r index = map (\ x -> (fst x) * width + (snd x)) $ find2DNeighbor height width r $ indexTo2DIndex width index

{- User has to make sure the grid corresponding to the index is non empty -}
{- Calculate the similarity score for specified grid in R-neighborhood in the Grid -}
similarityScore :: Grid Home -> Int -> Int -> Double
similarityScore (Grid {nRows = height, nCols = width, grid = lst}) r index = numIdentical / numNonEmpty where 
    neighbors =  map (lst !!) $ findNeighbor height width r index
    query = lst !! index
    numIdentical = fromIntegral $ length $ filter (\x -> x == query) neighbors
    numNonEmpty = fromIntegral $ length $ filter (\x -> x /= O) neighbors

{- Update one of the grid in the Grid with new home -}
updateGrid :: Grid Home -> Int -> Home -> Grid Home
updateGrid (Grid {nRows = height, nCols = width, grid = lst}) index home = Grid {nRows = height, nCols = width, grid = newLst} where
    newLst = take index lst ++ [home] ++ drop (index + 1) lst

{- Switch two grids in the Grid -}
{- Could be used to move home -}
switchGrid :: Grid Home -> Int -> Int -> Grid Home
switchGrid g@(Grid {nRows = height, nCols = width, grid = lst}) idx1 idx2 = updateGrid (updateGrid g idx1 home2) idx2 home1 where
    home1 = lst !! idx1
    home2 = lst !! idx2


{- Calulate the similarityScore if relocate to specified empty grid -}
relocationSimilarity :: Grid Home -> Int -> Int -> Int -> Double
relocationSimilarity g@(Grid {nRows = height, nCols = width, grid = lst}) r query target = similarityScore (switchGrid g query target) r target 


{- For list of (Int, Double), find the minimum tuple based on the second element in the tuple -}
minTuple :: [(Int, Double)] -> [(Int, Double)]
minTuple lst = foldl (\accum x -> if snd x == minimum then accum ++ [x] else accum) [] lst where 
    minimum = foldl (\accum x -> if snd x < accum then snd x else accum) (snd (head lst)) lst


{- Find optimal relocation grid -}
{-
findRelocation :: Grid Home -> [Int] -> Int -> Double -> Int -> Int
findRelocation g@(Grid {nRows = height, nCols = width, grid = lst}) queue r threshold query = if candidates == [] then query else (fst (head (minTuple candidates))) where
    candidates = filter (\x -> snd x >= threshold) $ zip queue $ map (relocationSimilarity g r query) queue
-}

findRelocation :: Grid Home -> [Int] -> Int -> Double -> Int -> Maybe Int
findRelocation g@(Grid {nRows = height, nCols = width, grid = lst}) queue r threshold query = if candidates == [] then Nothing else Just (fst (head (minTuple candidates))) where
    candidates = filter (\x -> snd x > threshold) $ zip queue $ map (relocationSimilarity g r query) queue


{- Relocate home -}
relocate :: (Grid Home, [Int]) -> Int -> Double -> Int -> (Grid Home, [Int])
relocate (g@(Grid {nRows = height, nCols = width, grid = lst}), queue) r threshold query = (newG, newQueue) where
    target = findRelocation g queue r threshold query
    home = lst !! query
    newG = if home /= O && (similarityScore g r query) < threshold && isNothing target == False then (switchGrid g query (fromJust target)) else g
    newQueue = if home /= O && (similarityScore g r query) < threshold && isNothing target == False then (filter (\x -> x /= fromJust target) queue) ++ [query] else queue 


{- Relocate all homes on board for one round -}
relocateAll :: (Grid Home, [Int]) -> Int -> Double -> (Grid Home, [Int])
relocateAll (g@(Grid {nRows = height, nCols = width, grid = lst}), queue) r threshold = foldl (\tuple query -> relocate tuple r threshold query) (g, queue) [0..n] where 
    n = height * width - 1


{- Satisfaction Rate -}
{- Calulate the percentage of the homes that are satisfied given the Grid Home -}
satisfactionRate :: Grid Home -> Int -> Double -> Double
satisfactionRate g@(Grid {nRows = height, nCols = width, grid = lst}) r threshold = fromIntegral (length $ filter (> threshold) $ map (\x -> similarityScore g r x) [0..n-1]) / fromIntegral n where n = height * width





testGrid1 = Grid {nRows = 4, nCols = 3, grid = [O, O, O, R, B, B, O, B, R, O, R, O]}

{-
[
[O, O, O]
[R, B, B]
[O, B, R]
[O, R, O]
]
-}

testGrid2 = Grid {nRows = 5, nCols = 5, grid = [R, R, O, R, R, O, B, B, B, O, R, R, R, R, B, B, B, B, O, B, B, R, R, R, O]}
queue2 = initializeQueue testGrid2