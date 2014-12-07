{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Risk where

import Control.Monad(replicateM)
import Control.Monad.Random
import Data.List(sort)


------------------------------------------------------------
-- Die values

newtype DieValue = DV { unDV :: Int }
  deriving (Eq, Ord, Show, Num)

first :: (a -> b) -> (a, c) -> (b, c)
first f (a, c) = (f a, c)

instance Random DieValue where
  random           = first DV . randomR (1,6)
  randomR (low,hi) = first DV . randomR (max 1 (unDV low), min 6 (unDV hi))

die :: Rand StdGen DieValue
die = getRandom



-- The die function simulates the roll of a die, picking a number between 1 and 6, inclusive,
-- and returning it in the Rand monad. Notice that this code will work with any source of random numbers g.

die' :: (RandomGen g) => Rand g Int
die' = getRandomR (1,6)
--The dice function uses replicate and sequence to simulate the roll of n dice.

dice :: (RandomGen g) => Int -> Rand g [Int]
dice n = sequence (replicate n die')
--To extract a value from the Rand monad, we can can use evalRandIO.



------------------------------------------------------------
-- Risk

type Army = Int

data Battlefield = Battlefield { attackers :: Army, defenders :: Army }



-- EXCERCISE 2

sortedDice :: (RandomGen g) => Int -> Rand g [Int]
sortedDice n = fmap sort results
    where results = dice n

twoRandomSets :: (RandomGen g) => Int -> Int -> Rand g ([Int], [Int])
twoRandomSets x y = (sortedDice x) >>= \i1 ->
                    (sortedDice y) >>= \i2 ->
                    return (i1, i2)

zipWithTail :: a -> [a] -> [a] -> [(a, a)]
zipWithTail mempty xs ys
    | length xs > length ys = zip xs (ys ++ padded)
    | length xs < length ys = zip (xs ++ padded) ys
    | otherwise             = zip xs ys
    where
        diff = length xs - length ys
        padded = take diff $ repeat mempty

carnage :: [Int] -> [Int] -> Battlefield
carnage x y = Battlefield att def
    where result = fmap (uncurry (>)) $ zipWithTail 0 x y
          att = length (filter (\x -> x == True) result)
          def = length (filter (\x -> x == False) result)


a = [1, 1, 1] :: [Int]
b = [5, 5] :: [Int]

-- This take a mini battlefield
battle' :: Battlefield -> Rand StdGen Battlefield
battle' x = fmap (uncurry carnage) (twoRandomSets (attackers x) (defenders x))


getAttackers :: Army -> (Army, Army)
getAttackers x
    | x > 3     = (x - 3, 3)
    | x == 3    = (x - 2, 2)
    | otherwise = (x - 1, 1)


getDefenders :: Army -> (Army, Army)
getDefenders x
    | x > 2     = (x - 2, 2)
    | x == 2    = (x - 2, 2)
    | otherwise = (x - 1, 1)

makeBattleField :: Battlefield -> Battlefield
makeBattleField bf = Battlefield (snd $ getAttackers (attackers bf)) (snd $ getDefenders (defenders bf))

remaining :: Battlefield -> Battlefield
remaining bf = Battlefield (fst $ getAttackers (attackers bf)) (fst $ getDefenders (defenders bf))


joinBattleField :: Battlefield -> Battlefield -> Battlefield
joinBattleField x y = Battlefield (attackers x + attackers y) (defenders x + defenders y)

joinBattleField' :: Battlefield -> Rand StdGen Battlefield -> Rand StdGen Battlefield
joinBattleField' x y = fmap (joinBattleField x) y

-- This one decides how many to attacke and defend with
battle :: Battlefield -> Rand StdGen Battlefield
battle bf
    | defenders bf == 0 = return bf
    | attackers bf < 2 = return bf
    | otherwise = joinBattleField' (remaining bf) (battle' (makeBattleField bf))




-- EXCERCISE 3


-- Implement this
-- Simulates an entire invasion attempt
-- repeated calls to battle until there are no defenders remainder
-- or fewer that two attackers

-- Now I have to apply the rules of results

-- attacker may attack with three units
-- but has to leave one behind
-- but not more than three


invade :: Battlefield -> Rand StdGen Battlefield
invade bf
    | defenders bf == 0 = return bf
    | attackers bf < 2 = return bf
    | otherwise = (battle bf) >>= invade






-- EXCERCISE 4
-- successProb :: Battlefield -> Rand StdGen Double

-- which runs invade 1000 times,
-- and uses the results to compute a Double between 0 and 1
-- representing the estimated probability that the attacking army will completely
-- destroy the defending army.
-- For example, if the defending army is destroyed in 300 of the 1000 simulations
-- (but the attacking army is reduced to 1 unit in the other 700),
-- successProb should return 0.3.

successProb_ :: [Battlefield] -> Double
successProb_ xs = (fromIntegral num_wins) / (fromIntegral $ length xs)
    where num_wins = length (filter (\x -> defenders x == 0) xs)

successProb :: Battlefield -> Rand StdGen Double
successProb bf = fmap successProb_ collection
    where collection = replicateM 1000 (invade bf)





-- DEBUGGING
battle_field = Battlefield 5 5


render' :: Battlefield -> String
render' bf = "Attackers: " ++ (show $ attackers bf) ++ " Defenders: " ++ (show $ defenders bf)

render :: IO Battlefield -> IO String
render bf = fmap render' bf

doit = evalRandIO (successProb battle_field)














