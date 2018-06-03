
import Graphics.Gloss.Interface.IO.Game 
import Graphics.Gloss
import System.Environment

import Display
import Grid
import GridIO

--heightGrid = 15
--widthGrid = 15
--percentageEmpty = 40
--percentageRed = 50
--percentageBlue = 50
--thresholdInit = 0.45
--thresholdIntInit = 45
thresholdIntInitDefault = 45
--rInit = 2
rInitDefault = 2
--maxTimeStepInit  = 30



readState :: [String] -> IO State
readState [arg0, arg1, arg2, arg3, arg4]
    | (isStringInt arg1) == True = do
        let maxTimeStepInit = readInt $ arg0
        let heightGrid = readInt $ arg1
        if heightGrid > 15 || heightGrid < 5 then do error "Grid size is between 5 to 15." else do
        let widthGrid = heightGrid
        let percentageEmpty = readInt $ arg4
        if percentageEmpty > 100 || percentageEmpty < 0 then do error "Percentage Empty is between 0 to 100." else do
        let percentageRed = readInt $ arg2
        if percentageRed > 100 || percentageRed < 0 then do error "Percentage Red is between 0 to 100." else do
        let percentageBlue = readInt $ arg3
        if percentageBlue > 100 || percentageBlue < 0 then do error "Percentage Blue is between 0 to 100." else do
        if percentageRed + percentageBlue /= 100 then do error "Percentage red plus percentage blue should be 100." else do
        initState heightGrid widthGrid percentageEmpty percentageRed percentageBlue thresholdIntInitDefault rInitDefault maxTimeStepInit
    | (isStringInt arg1) == False = do
        gridLoaded@(Grid {nRows = nr, nCols = nc, grid = homeList}) <- readGrid arg1
        if nr > 15 || nr < 5 || nc > 15 || nc < 5 then do error "Grid size is between 5 to 15." else do
        let maxTimeStepInit = readInt $ arg0
        let (numO, numR, numB) = countHome homeList
        let queueInit = initializeQueue gridLoaded
        return State {board = gridLoaded, queue = queueInit, threshold = fromIntegral thresholdIntInitDefault / 100, neighborSize = rInitDefault, elaspedTime = 0, timeStep = 0, maxTimeStep = maxTimeStepInit, pause = True, equilibrated = False, pEmpty = numO * 100 `div` (numR + numB + numO), pRed = numR * 100 `div` (numR + numB), pBlue = numB * 100 `div` (numR + numB)}
readState _ = error "Argument Error!"


main :: IO() 
main = do

    args <- getArgs
    stateInit <- readState args
    --stateInit <- initState heightGrid widthGrid percentageEmpty percentageRed percentageBlue thresholdIntInit rInit maxTimeStepInit
    playIO window white fps stateInit render eventHandler updateLoop 