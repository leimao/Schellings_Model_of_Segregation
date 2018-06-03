
module Display
(
    State(..),
    screenSize,
    window,
    fps,
    initState,
    render,
    eventHandler,
    updateLoop,
) where


import Graphics.Gloss.Interface.IO.Game 
import Graphics.Gloss

import Grid
import Simulation
import Shuffle


screenSize :: (Int, Int)
screenSize = (768, 1024)

window :: Display 
window = InWindow "Schelling's Model" screenSize (10, 10)


fps:: Int 
fps = 60 


redColor :: Color 
redColor = makeColor 1.0 0.0 0.0 1.0 

blueColor :: Color 
blueColor = makeColor 0.0 0.0 1.0 1.0 

whiteColor :: Color 
whiteColor = makeColor 1.0 1.0 1.0 1.0 

homeColor :: Home -> Color
homeColor home 
    | home == R = redColor
    | home == B = blueColor
    | otherwise = whiteColor


{- Calculate the optimal squre size for the screen given the screenSize and the number of grids -}
squareSize :: (Int, Int) -> Int -> Int -> (Int, Int)
squareSize (ph, pw) numRows numCols = (length, length) where 
    length = min (round (fromIntegral ph / (fromIntegral numRows * 1.5))) (round (fromIntegral pw / (fromIntegral numCols * 1.5)))

{- Given number rows and columns, the size of grids, return the coodinates of each grid -}
{- nRows, nCols, shifts relatives to origin, height and width for single lattice -}
squareCoordinates :: Int -> Int -> (Int, Int) -> (Int, Int) -> [(Int, Int)]
squareCoordinates nr nc (shiftX, shiftY) (gh, gw) = map (\ (i, j) -> (j * gw + shiftX, - i * gh + shiftY)) $ indicesTo2DIndicies nc [0..n] where n = (nr * nc - 1)

data State = State {board :: Grid Home, queue :: [Int], threshold :: Double, neighborSize :: Int, elaspedTime :: Float, timeStep :: Int, maxTimeStep :: Int, pause :: Bool, equilibrated :: Bool, pEmpty :: Int, pRed :: Int, pBlue :: Int}
    deriving (Eq, Show)


squarePictures :: State -> [Picture]
squarePictures state@(State {board = Grid {nRows = nr, nCols = nc, grid = lst}}) = map (\(g, (x, y)) -> translate (fromIntegral x) (fromIntegral y).color(homeColor g) $ (rectangleSolid (fromIntegral gw) (fromIntegral gh))) $ zip lst coodinates where 
    (gh, gw) = squareSize screenSize nr nc
    coodinates = squareCoordinates nr nc (- (nc-1) * gw `div` 2, (nr-1) * gh `div` 2 + (snd screenSize) `div` 8) (gh, gw)

boarderPictures :: State -> [Picture]
boarderPictures state@(State {board = Grid {nRows = nr, nCols = nc, grid = lst}}) = map (\(g, (x, y)) -> translate (fromIntegral x) (fromIntegral y) $ (rectangleWire (fromIntegral gw) (fromIntegral gh))) $ zip lst coodinates where 
    (gh, gw) = squareSize screenSize nr nc
    coodinates = squareCoordinates nr nc (- (nc-1) * gw `div` 2, (nr-1) * gh `div` 2 + (snd screenSize) `div` 8) (gh, gw)

parameterPictures :: State -> [Picture]
parameterPictures state@(State {board = Grid {nRows = nr, nCols = nc, grid = lst}, queue = q, threshold = t, neighborSize = r, elaspedTime = e, timeStep = ts, maxTimeStep = mts, pause = p, equilibrated = eq, pEmpty = pe, pRed = pr, pBlue = pb}) = [titleMessage, roundMessage, equilibriumMessage, equilibriumHelperMessage, pauseMessage, pauseHelperMessage, stepHelperMessage, neighborSizeMessage, neighborSizeHelperMessage, thresholdMessage, thresholdHelperMessage, satisfactionMessage, pEmptyMessage, pRedBlueRatioMessage, sizeMessage]
    where
        titleMessage = translate (fromIntegral (-(fst screenSize) * 10 `div` 24)) (fromIntegral ((snd screenSize) * 10 `div` 24)).scale 0.25 0.25.text $ "Schelling's Model of Housing Segregation"
        roundMessage = translate (fromIntegral (-(fst screenSize) * 63 `div` 192)) (fromIntegral (-(snd screenSize) * 7 `div` 48)).scale 0.1 0.1.text $ "Round: " ++ (show ts) ++ "/" ++ (show mts)
        equilibriumMessage = translate (fromIntegral ((fst screenSize) * 9 `div` 48)) (fromIntegral (-(snd screenSize) * 7 `div` 48)).scale 0.1 0.1.text $ "Equilibrium: " ++ (show eq)
        equilibriumHelperMessage = translate (fromIntegral ((fst screenSize) * 23 `div` 96)) (fromIntegral (-(snd screenSize) * 8 `div` 48)).scale 0.1 0.1.text $ "r to reset"
        satisfactionMessage = translate (fromIntegral (-(fst screenSize) * 63 `div` 192)) (fromIntegral (-(snd screenSize) * 8 `div` 48)).scale 0.1 0.1.text $ "Satisfied: " ++ show (floor ((satisfactionRate (Grid {nRows = nr, nCols = nc, grid = lst}) r t) * 100)) ++ "%"
        pauseMessage = translate (fromIntegral (-(fst screenSize) * 3 `div` 96)) (fromIntegral (-(snd screenSize) * 7 `div` 48)).scale 0.1 0.1.text $ if p == True then "Paused" else "Running"
        pauseHelperMessage = translate (fromIntegral (-(fst screenSize) * 12 `div` 96)) (fromIntegral (-(snd screenSize) * 8 `div` 48)).scale 0.1 0.1.text $ "space to start/pause/resume"
        stepHelperMessage = translate (fromIntegral (-(fst screenSize) * 14 `div` 96)) (fromIntegral (-(snd screenSize) * 9 `div` 48)).scale 0.1 0.1.text $ "s/b to run manually/automatically"


        neighborSizeMessage = translate (fromIntegral (-(fst screenSize) * 63 `div` 192)) (fromIntegral (-(snd screenSize) * 11 `div` 48)).scale 0.15 0.15.text $ "R-size: " ++ show r
        neighborSizeHelperMessage = translate (fromIntegral (-(fst screenSize) * 9 `div` 192)) (fromIntegral (-(snd screenSize) * 11 `div` 48)).scale 0.1 0.1.text $ "left/right adjust neighbor size"
        thresholdMessage = translate (fromIntegral (-(fst screenSize) * 63 `div` 192)) (fromIntegral (-(snd screenSize) * 12 `div` 48)).scale 0.15 0.15.text $ "Threshold: " ++ show (round (t * 100)) ++ "%"
        thresholdHelperMessage = translate (fromIntegral (-(fst screenSize) * 9 `div` 192)) (fromIntegral (-(snd screenSize) * 12 `div` 48)).scale 0.1 0.1.text $ "up/down adjust neighbor size"
        pEmptyMessage = translate (fromIntegral (-(fst screenSize) * 63 `div` 192)) (fromIntegral (-(snd screenSize) * 13 `div` 48)).scale 0.15 0.15.text $ "Empty: " ++ show pe ++ "%"
        pRedBlueRatioMessage = translate (fromIntegral (-(fst screenSize) * 63 `div` 192)) (fromIntegral (-(snd screenSize) * 14 `div` 48)).scale 0.15 0.15.text $ "Red/Blue: " ++ show pr ++ "%" ++ "/" ++ show pb ++ "%"
        sizeMessage = translate (fromIntegral (-(fst screenSize) * 63 `div` 192)) (fromIntegral (-(snd screenSize) * 15 `div` 48)).scale 0.15 0.15.text $ "Size: " ++ show nr ++ "x" ++ show nc

render :: State -> IO Picture 
render state@(State {board = Grid {nRows = nr, nCols = nc, grid = lst}}) = return $ pictures $ (squarePictures state) ++ (boarderPictures state) ++ (parameterPictures state)

{-
initState' :: IO State 
initState' = do
    let boardInit@(Grid {nRows = nr, nCols = nc, grid = lst}) = initializeGrid heightGrid widthGrid percentageEmpty percentageRed percentageBlue
    lstShuffled <- shuffle lst
    let boardShuffled = Grid {nRows = nr, nCols = nc, grid = lstShuffled}
    let queueInit = initializeQueue boardShuffled
    let stateInit = State {board = boardShuffled, queue = queueInit, threshold = thresholdInit, neighborSize = rInit, elaspedTime = 0, timeStep = 0, maxTimeStep = maxTimeStepInit, pause = True, equilibrated = False, pEmpty = percentageEmpty, pRed = percentageRed, pBlue = percentageBlue}
    return stateInit
-}

initState :: Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int -> IO State
initState height width pe pr pb threshold r maxts = do
    let boardInit@(Grid {nRows = nr, nCols = nc, grid = lst}) = initializeGrid height width pe pr pb
    lstShuffled <- shuffle lst
    let boardShuffled = Grid {nRows = nr, nCols = nc, grid = lstShuffled}
    let queueInit = initializeQueue boardShuffled
    let stateInit = State {board = boardShuffled, queue = queueInit, threshold = fromIntegral threshold / 100, neighborSize = r, elaspedTime = 0, timeStep = 0, maxTimeStep = maxts, pause = True, equilibrated = False, pEmpty = pe, pRed = pr, pBlue = pb}
    return stateInit


nextState :: State -> State
nextState state@(State {board = b, queue = q, threshold = t, neighborSize = r, elaspedTime = e, timeStep = ts, maxTimeStep = mts, pause = p, pEmpty = pe, pRed = pr, pBlue = pb})
    | ts >= mts = state
    | otherwise = State {board = newGrid, queue = newQueue, threshold = t, neighborSize = r, elaspedTime = 0, timeStep = ts + 1, maxTimeStep = mts, pause = p, equilibrated = (newGrid == b) && (newQueue == q), pEmpty = pe, pRed = pr, pBlue = pb} where (newGrid, newQueue) = relocateAll (b, q) r t


eventHandler :: Event -> State -> IO State 
eventHandler (EventKey (SpecialKey key) Up _ _) state@(State {board = b, queue = q, threshold = t, neighborSize = r, elaspedTime = e, timeStep = ts, maxTimeStep = mts, pause = p, equilibrated = eq, pEmpty = pe, pRed = pr, pBlue = pb}) = 
    case key of
        {- Increase threshold -}
        KeyUp -> return (State {board = b, queue = q, threshold = min (t + 0.05) 1.0, neighborSize = r, elaspedTime = e, timeStep = ts, maxTimeStep = mts, pause = p, equilibrated = False, pEmpty = pe, pRed = pr, pBlue = pb})
        {- Decrease threshold -}
        KeyDown -> return (State {board = b, queue = q, threshold = max (t - 0.05) 0.0, neighborSize = r, elaspedTime = e, timeStep = ts, maxTimeStep = mts, pause = p, equilibrated = False, pEmpty = pe, pRed = pr, pBlue = pb})
        {- Increase neighborSize -}
        KeyLeft -> if p == True && ts == 0 then return (State {board = b, queue = q, threshold = t, neighborSize = r + 1, elaspedTime = e, timeStep = ts, maxTimeStep = mts, pause = p, equilibrated = eq, pEmpty = pe, pRed = pr, pBlue = pb}) else return state
        {- Decrease neighborSize -}
        KeyRight -> if p == True && ts == 0 then return (State {board = b, queue = q, threshold = t, neighborSize = max (r - 1) 0, elaspedTime = e, timeStep = ts, maxTimeStep = mts, pause = p, equilibrated = eq, pEmpty = pe, pRed = pr, pBlue = pb}) else return state 
        {- Pause/Run -}
        KeySpace -> return (State {board = b, queue = q, threshold = t, neighborSize = r, elaspedTime = e, timeStep = ts, maxTimeStep = mts, pause = not p, equilibrated = eq, pEmpty = pe, pRed = pr, pBlue = pb})
        {- Otherwise -}
        _ -> return state
eventHandler (EventKey (Char key) Up _ _) state@(State {board = b@(Grid {nRows = nr, nCols = nc, grid = lst}), queue = q, threshold = t, neighborSize = r, elaspedTime = e, timeStep = ts, maxTimeStep = mts, pause = p, equilibrated = eq, pEmpty = pe, pRed = pr, pBlue = pb}) = 
    case key of
        's' -> if ts == mts then return state else return $ nextState pausedState where pausedState = State {board = b, queue = q, threshold = t, neighborSize = r, elaspedTime = e, timeStep = ts, maxTimeStep = mts, pause = True, equilibrated = eq, pEmpty = pe, pRed = pr, pBlue = pb}
        'b' -> if ts == mts then return state else return $ nextState resumedState where resumedState = State {board = b, queue = q, threshold = t, neighborSize = r, elaspedTime = e, timeStep = ts, maxTimeStep = mts, pause = False, equilibrated = eq, pEmpty = pe, pRed = pr, pBlue = pb}
        'r' -> initState nr nc pe pr pb (round (t * 100)) r  mts
        _ -> return state
eventHandler _ state = return state  


updateLoop :: Float -> State -> IO State 
updateLoop deltaTime state@(State {board = b, queue = q, threshold = t, neighborSize = r, elaspedTime = eTime, timeStep = ts, maxTimeStep = mts, pause = p, equilibrated = eq, pEmpty = pe, pRed = pr, pBlue = pb}) 
    | ts == mts = return state
    | (p == True) || (eq == True) = return state {- | p == True = return state -}
    | otherwise = let
        eTime' = eTime + deltaTime
        in 
            if eTime' > 1.0 
                then do 
                    return $ nextState state
            else return (State {board = b, queue = q, threshold = t, neighborSize = r, elaspedTime = eTime', timeStep = ts, maxTimeStep = mts, pause = p, equilibrated = eq, pEmpty = pe, pRed = pr, pBlue = pb})







