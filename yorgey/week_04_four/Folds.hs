-- CIS 194 Homework 4

module Folds where

import Data.List


-- EXERCISE 1


-- Reimplement each of the following functions in a more idiomatic
-- Haskell style. Use wholemeal programming practices, breaking each function
-- into a pipeline of incremental transformations to an entire data structure.
-- Name your functions fun1’ and fun2’ respectively.

-- Hint: For this problem you may wish to use the functions iterate and takeWhile.
-- Look them up in the Prelude documentation to see what they do.

fun1 :: [Integer] -> Integer
fun1 []          = 1
fun1 (x:xs)
     | even x    = (x - 2) * fun1 xs
     | otherwise = fun1 xs



-- This is wrong
fun1' = foldl1 (*) . map (\x -> x - 2) . takeWhile (even)
-- fun1' = foldr (\x accum -> if (even x) then (accum * (x - 2)) else accum) 1
--fun1' =  foldl1 (*) . map (\x -> if (even x) then (x - 2) else 1)
fun1' :: [Integer] -> Integer


-- This is right, but it is not that wholemealish
fun1'' = foldl (\accum x -> if even x then accum * (x-2) else accum) 1





fun2 :: Integer -> Integer
fun2 1               = 0
fun2 n  | even n     = n + fun2 (n `div` 2)
        | otherwise  = fun2 (3 * n + 1)




-- Returns
-- Bool -> Integer -> Integer
h = \x -> if x then (`div` 2) else (1+).(3*)

-- Forces me to duplicate the last value
-- (h . even) 5 5

 --(1+).(3*)
f :: Integer -> Integer
f x = if even x then (x `div` 2) else (3 * x + 1)
fun2' =  foldl (\acc x -> if even x then acc + x else acc) 0 . takeWhile (>1) . iterate f
--fun2' =  foldl (\acc x -> if even x then acc + x else acc) 0 . takeWhile (>1) . iterate (h . even)






a = [1, 1, 1]
b = [1, 2, 3, 4, 5, 6, 7]
c = [2, 4, 8, 3, 4, 2, 6]
d = [10, 7, 8, 6, 4, 3, 6, 7]



-- Confirmed. Sum can be implemented with both a left and right fold
sum' = foldl1 (\accum x -> accum + x)
sum'' = foldr1 (\x accum -> accum + x)


maximum' :: (Ord a) => [a] -> a
maximum' = foldl1 (\accum x -> if accum > x then accum else x)

maximum'' :: (Ord a) => [a] -> a
maximum'' = foldr1 (\x accum -> if accum > x then accum else x)

reverse' = foldl (\x acc -> acc : x) []






-- EXERCISE 2

--Recall the definition of a binary tree data structure. The height of
--a binary tree is the length of a path from the root to the deepest node. For example, the height of a tree with a single node is 0; the height of a tree with three nodes, whose root has two children, is 1; and so on. A binary tree is balanced if the height of its left and right subtrees differ by no more than 1, and its left and right subtrees are also balanced.


-- You should use the following data structure to represent binary trees. Note that each node stores an extra Integer representing the height at that node.

data Tree a = Leaf
            | Node Integer (Tree a) a (Tree a)
    deriving (Show, Eq)

-- For this exercise, write a function


--foldTree :: [a] -> Tree a











