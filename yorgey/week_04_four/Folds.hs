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

fun1' :: [Integer] -> Integer
fun1' = foldl1 (*) . map (\x -> x - 2) . filter (even)




fun2 :: Integer -> Integer
fun2 1               = 0
fun2 n  | even n     = n + fun2 (n `div` 2)
        | otherwise  = fun2 (3 * n + 1)

fun2' :: Integer -> Integer
fun2' = sum . filter (even) . takeWhile (>1) . iterate z
    where
        z = j . k
        j = uncurry (h . even)
        k = \x -> (x, x)
        h = \x -> if x then (`div` 2) else (1+).(3*)




-- Confirmed. Sum can be implemented with both a left and right fold
sum' = foldl1 (\accum x -> accum + x)
sum'' = foldr1 (\x accum -> accum + x)


maximum' :: (Ord a) => [a] -> a
maximum' = foldl1 (\accum x -> if accum > x then accum else x)

maximum'' :: (Ord a) => [a] -> a
maximum'' = foldr1 (\x accum -> if accum > x then accum else x)

reverse' = foldl (\x acc -> acc : x) []






-- EXERCISE 2

-- Recall the definition of a binary tree data structure. The height of
-- a binary tree is the length of a path from the root to the deepest node.
-- For example, the height of a tree with a single node is 0; the height of a tree with three nodes,
-- whose root has two children, is 1; and so on.
-- A binary tree is balanced if the height of its left and right subtrees differ by no more than 1,
-- and its left and right subtrees are also balanced.


-- You should use the following data structure to represent binary trees.
-- Note that each node stores an extra Integer representing the height at that node.

data Tree a = Leaf
            | Node Integer (Tree a) a (Tree a)
    deriving (Show, Eq)


-- which generates a balanced binary tree from a list of values using foldr.


tr = "ABCDEFGHIJ"

tree_a = Node 0 Leaf "A" Leaf
tree_b = Node 0 Leaf "B" Leaf
tree_c = Node 0 Leaf "C" Leaf
tree_d = Node 0 Leaf "D" Leaf
tree_e = Node 0 Leaf "E" Leaf
tree_f = Node 0 Leaf "F" Leaf
tree_g = Node 0 Leaf "G" Leaf

tree_ba = insertTree tree_a tree_b
tree_bac = insertTree tree_c tree_ba
tree_bacd = insertTree tree_d tree_bac
tree_bacde = insertTree tree_e tree_bacd
tree_bacdef = insertTree tree_f tree_bacde
tree_bacdefg = insertTree tree_g tree_bacdef




-- STARTEGY A: Create a balanced tree


-- STARTEGY B: Left, right, left, right

-- L, R,  LL, LR, RL, RR,  LLL, LLR, LRL, LRR, RLL, RLR, RRL, RRR
-- These look like permutations
-- Not quite


-- STARTEGY C: Recursive insert into unbalanced position



-- treeHeight, also disperses - and it is amazing that it comes to a conclusion
-- it assumes that all the child nodes have the correct height set
-- I'm not feeling a strong case for why I need it
treeHeight :: Tree a -> Integer
treeHeight Leaf = 0
treeHeight (Node h left _ right)
    | left_height >= right_height = left_height + 1
    | left_height <  right_height = right_height + 1
    where left_height = treeHeight left
          right_height = treeHeight right


-- [?] Can something that disperses, be folded?
-- There is a particular situation, which makes treeWeight necessary
treeWeight :: Tree a -> Integer
treeWeight Leaf = 1
treeWeight (Node h left _ right) = treeWeight left + treeWeight right



-- w_right <  w_left  = Node newHeight new n right

-- what is the evalation order of w_left?

-- insertTree does not disperse - it follows a dynamically decided path

-- TOOD: I can get rid the of the first pattern match, because I am not inserting
-- a tree into a leaf
-- wait, this is not true
-- maybe takeWhile will save me
insertTree :: Tree a -> Tree a -> Tree a
insertTree new Leaf = new
insertTree new (Node h left n right)
    | w_left  >  w_right = Node (treeHeight new_right) left n new_right
    | w_right <= w_left = Node (treeHeight new_left) new_left n right
    where new_left = insertTree new left
          new_right = insertTree new right
          w_left = treeWeight left
          w_right = treeWeight right



-- [?] Fold left works just as well
foldTree :: [a] -> Tree a
foldTree = foldr1 (\x acc -> insertTree x acc) . map (\x -> Node 0 Leaf x Leaf)


-- NEXT: A foldr implemention of insertTree

--insertTree' = iterate
--    where
--        fth = \x -> if x then (Node (treeHeight new_right) left n new_right) else (Node (treeHeight new_left) new_left n right)
--        new_left = insertTree new left
--        new_right = insertTree new right

fgx x (Node h left n right)
    | x     = Node (treeHeight new_right) left n new_right
    | not x = Node (treeHeight new_left) new_left n right
    where new_left = insertTree new left
          new_right = insertTree new right




-- EXERCISE 3.1: More Folds
-- returns True if and only if there are an odd number of True values in the input list
xor :: [Bool] -> Bool
xor = foldl (\x acc -> if x then not acc else acc) False


-- EXERCISE 3.2: More Folds
-- implement map as a fold
map' :: (a -> b) -> [a] -> [b]
map' f = foldr (\x acc -> f x : acc) []

-- EXERCISE 3.3: Implement foldl using foldr..










-- EXERCISE 4:

-- Implement the algorithm using function composition.
-- Given an integer n, your function should generate all the odd prime numbers up to 2n + 2.

cartProd :: [a] -> [b] -> [(a, b)]
cartProd xs ys = [(x,y) | x <- xs, y <- ys]

-- [?] How do I source the input right in the middle?
-- [?] Can I over-apply?
--sieveSundaram :: Integer -> [Integer]
sieveSundaram n = map (\x -> x * 2 + 1) . eliminate' . do_mult . filter_cart . uncurry cartProd . source'
    where eliminate'         = eliminate [1..n]
          eliminate xs subs  = foldr (\x acc -> if (elem x subs) then acc else x : acc) [] xs
          do_mult            = foldr (\(i,j) acc -> i + j + 2 * i * j : acc) []
          filter_cart        = filter (\(i,j) -> i <= j)
          source'            = (\x -> (x, x)) . (\x -> [1..x])

-- Cannot apply a tuple of three into cartProd
overapply = uncurry cartProd . source'
    where
          source'            = (\x -> (x, x)) . (\x -> [1..x])
