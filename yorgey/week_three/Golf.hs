-- CIS 194 Homework 3

module Golf where

import Data.List

-- Skips
-- The output is a list of lists
-- The first list in the output should be the same as the input list
-- The second list in the output should contain every second element from the input list
-- and the nth list in the output should contain every nth element

-- skips "ABCD"       == ["ABCD", "BD", "C", "D"]
-- skips "hello!"     == ["hello!", "el!", "l!", "l", "o", "!"]
-- skips [1]          == [[1]]
-- skips [True,False] == [[True,False], [False]]
-- skips []           == []

-- the output should be the same length as the input




scatter :: Int -> [t] -> [t]
scatter n x = [x | (x,y) <- zipped, y == True ]
    where zipped = zip (x) (mask n (length x))

scatter' :: ([t], Int) -> [t]
scatter' (x, n) = [x | (x,y) <- zipped, y == True ]
    where zipped = zip (x) (mask n (length x))

mask :: Int -> Int -> [Bool]
mask n l = take l (cycle pattern)
    where pattern = (replicate (n-1) (False)) ++ [True]

skips x = map scatter' (source x)
    where source x = zip (replicate (length x) x) ([1..(length x)])



-- Try a different perspective
-- Create a function that creates a function for each item

--a = [1..10]
a = [2,9,5,6,1]



generator :: [t] -> Int ->  [t]
generator xs n = xs


some_func xs = map gen source
    where gen = generator xs
          source = [1.. (length xs)]


-- Local Maxima
-- A local maximum of a list
-- is an element of the list which is strictly
-- greater than both the elements
-- immediately before and after it.

-- For example, in the list [2,3,4,1,5], the only local maximum is 4,
-- since it is greater than the elements immediately before and after it (3 and 1).
-- 5 is not a local maximum since there is no element that comes after it.

--localMaxima [2,9,5,6,1] == [9,6]
--localMaxima [2,3,4,1,5] == [4]
--localMaxima [1,2,3,4,5] == []

localMaxima :: [Integer] -> [Integer]
localMaxima a = a


local [] = []



something xs = zip (replicate (length xs) xs) indexes
    where indexes = [0..((length xs) - 1)]


doit xs = map subsets (something xs)
    where subsets (xs, n) = take 3 (drop n xs)





-- which takes as input a list of Integers between 0 and 9 (inclusive),
-- and outputs a vertical histogram showing how many of each number were in the input list.
-- You may assume that the input list does not contain any numbers less than zero
-- or greater than 9
-- (that is, it does not matter what your function does if the input does contain such numbers).
-- Your output must exactly match the output shown in the examples below.

-- histogram [1,1,1,5] ==
-- *
-- *
-- *   *
-- ==========
-- 0123456789


-- histogram [1,4,5,4,6,6,3,4,2,4,9] ==
--     *
--     *
--     * *
--  ******  *
-- ==========
-- 0123456789


-- Important note: If you type something like histogram [3,5] at the ghci prompt,
-- you should see something like this:
-- "   * *    \n==========\n0123456789\n"

-- This is a textual representation of the String output,
-- including \n escape sequences to indicate newline characters.
-- To actually visualize the histogram as in the examples above, use putStr,
-- for example, putStr (histogram [3,5]).

histogram :: [Integer] -> String
histogram a = "bob"

-- might have to do a transpose
