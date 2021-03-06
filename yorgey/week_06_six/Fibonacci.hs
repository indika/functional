{-# LANGUAGE FlexibleInstances #-}
{-# OPTIONS_GHC -fno-warn-missing-methods #-}

import Data.List

-- Fibonacci numbers
-- TODO: See the Euler problem



-- The Fibonacci numbers Fn are deﬁned as the sequence of integers,
-- beginning with 0 and 1, where every integer in the sequence is the
-- sum of the previous two. That is,
-- F0 = 0
-- F1 = 1
-- Fn = Fn−1 + Fn−2 (n ≥ 2)

-- For example, the ﬁrst ﬁfteen Fibonacci numbers are
-- 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, . . .

-- It’s quite likely that you’ve heard of the Fibonacci numbers before.
-- The reason they’re so famous probably has something to do with the
-- simplicity of their deﬁnition combined with the astounding variety of
-- ways that they show up in various areas of mathematics as well as art
-- and nature.


-- EXERCISE 1

-- Translate the above deﬁnition of Fibonacci numbers directly into a
-- recursive function deﬁnition of type
-- so that fib n computes the nth Fibonacci number Fn.

fib :: Integer -> Integer
fib x
    | x == 0 = 0
    | x == 1 = 1
    | otherwise = fib (x - 1) + fib (x - 2)

-- Now use fib to deﬁne the inﬁnite list of all Fibonacci numbers,
fibs1 :: [Integer]
fibs1 = map fib positive_integers
    where positive_integers = [0..]



-- (Hint: You can write the list of all positive integers as [0..].)
-- Try evaluating fibs1 at the ghci prompt. You will probably get
-- bored watching it after the ﬁrst 30 or so Fibonacci numbers, because
-- fib is ridiculously slow. Although it is a good way to deﬁne the Fi
-- bonacci numbers, it is not a very good way to compute them—in order
-- to compute Fn it essentially ends up adding 1 to itself Fn times!

-- For example, shown at right is the tree of recursive calls made by evaluating fib 5.
-- As you can see, it does a lot of repeated work. In the end, fib has running time
-- O(Fn), which (it turns out) is equivalent to O(ro squared) where ro = 1 + root 5 / 2
-- is the golden ratio
-- That’s right, the running time is exponential in n.
-- What’s more, all this work is also repeated from each element of the list fibs1 to the next.

-- What is this thing?
-- It is a sequence. It's value is basically the sum of the previous two values.
-- The initial calculation of it does not use the previous value.
-- It does everything again.
-- If there are n items, then it has to do n steps.
-- Each successive element requires exponential growth.






-- EXERCISE 2

-- Your task for this exercise is to come up with more efficient implementation.
-- Specifically, define the infinite list

-- fibs2 :: [Integer]
-- so that it has the same elements as fibs1,
-- but computing the first n elements of fibs2 requires only O(n) addition operations.
-- Be sure to use standard recursion pattern(s) from the Prelude as appropriate.




-- try iterating
fib_append :: Num a => [a] -> [a]
fib_append (x:xs) =  (x + head xs) : x : xs

starting = [2, 1]
fib_reversed = take 5 (iterate fib_append starting)



-- This creates a new list for each new number
-- I just need to produce an infinite list of fib integers

--fibs2 = scanl gl [] positive_integers
--    where positive_integers = [0..]

fibs2 :: [Integer]
fibs2 = 1 : 2 : zipWith (+) fibs2 (tail fibs2)

-- [?] How can I get past not having to pass a list into the function, and it returning a list
-- I can't just return a value

-- [?] What causes something to be displayed on the screen?


-- STREAMS

-- Define a Stream type representing lists that must be infinite
-- This way we can be more explicit about infinite lists
-- Usual list type represents both infinite, and finite
-- In particular, streams are like lists but with only a “cons” constructor
-- (whereas the list type has two constructors, [] (the empty list) and (:) (cons) )
-- There is no such thing as an empty stream.
-- So a stream is simply defined as an element followed by a stream.




-- EXERCISE 3

-- Define a data type of polymorphic streams, Stream.

data Stream a = a :. Stream a


-- Write a function to convert a Stream to an infinite list,
streamToList :: Stream a -> [a]
streamToList (x :. y) = x : streamToList y
-- streamToList (InfiniteCons x y) = x : streamToList y



-- Have an instance of Show for Streams
-- This will help test the Stream functions in the succeeding exercises
-- Deriving Show is in sufficient, because the resulting instance will try to print on when it finishes
-- Instead, make my own instance of Show

instance Show a => Show (Stream a) where
    show stream = show (take 20 (streamToList stream))

-- show stream = show . foldr (:) [] (streamToList stream)

-- which works by showing only some prefix of a stream (say, the first 20 elements).
-- Hint: you may find your streamToList function useful.





-- EXERCISE 4

-- This generates a stream containing infinitely many copies of the given element
streamRepeat :: a -> Stream a
streamRepeat x = x :. (streamRepeat x)


-- which applies a function to every element of a Stream.
streamMap :: (a -> b) -> Stream a -> Stream b
streamMap f (x :. y) = f x :. ( streamMap f y)

-- which generates a Stream from a “seed” of type a,
-- this "seed", is the first element of the stream,
-- and an "unfolding rule" of type a -> a
-- this specifies how to transform the seed into a new seed
-- and be used for generating the rest of the stream
streamFromSeed :: (a -> a) -> a -> Stream a
streamFromSeed f x = x :. (streamFromSeed f (f x))







-- EXERCISE 5

-- Create a few streams, with the tools we have now

-- An inifinite list of natural numbers 0, 1, 2, . . .
nats :: Stream Integer
nats = streamFromSeed (\x -> x + 1) 0

--interleaveStreams :: Stream a -> Stream a -> Stream a
--interleaveStreams (x :. x') (y :. y') = x :. (y :. interleaveStreams x' y')

-- Do not pattern match on both
interleaveStreams :: Stream a -> Stream a -> Stream a
interleaveStreams (x :. xs) y = x :. (interleaveStreams y xs)


-- The ruler function
-- 0,1, 0,2, 0,1, 0,3, 0,1, 0,2, 0,1, 0,4, ...
-- where the nth element in the stream (assuming the first element corresponds to n = 1)
-- is the largest power of 2 which evenly divides n.
-- Try to implement this in a clever way that does not do any divisibility testing

ruler :: Stream Integer
ruler = ruler' 0
    where ruler' n = interleaveStreams (streamRepeat n) (ruler' (n+1))






-- FIBONACCI NUMBERS VIA GENERATING FUNCTIONS (EXTRA CREDIT)

-- This section is optional but very cool, so if you have time I hope you will try it.
-- We will use streams of Integers to compute the Fibonacci numbers in an astounding way.

-- The essential idea is to work with generating functions of the form
-- a0 + a1x + a2x2 +···+ anxn +...
-- where x is just a “formal parameter”
-- (that is, we will never actually substitute any values for x; we just use it as a placeholder)
-- and all the coefficients ai are integers.
-- We will store the coefficients a0, a1, a2, . . . in a Stream Integer.


-- Exercise 6 (Optional) • First, define
--   x :: Stream Integer
-- by noting that x = 0 + 1x + 0x2 + 0x3 + . . . .

-- • Define an instance of the Num type class for Stream Integer.
-- want to define a stream of co-efficients to accompany an Integer



instance Num (Stream Integer) where

    -- You should implement the fromInteger function. Note that
    -- n = n + 0x + 0x2 + 0x3 +....
    fromInteger x = x :. streamRepeat 0

    -- Negate the stream, i.e, negate all the coefficients
    negate = streamMap (\x -> x * (-1))

    -- You should implement (+), which works like you would expect:
    -- (a0 +a1x+a2x2 +...)+(b0 +b1x+b2x2 +...) = (a0 +b0)+ (a1 +b1)x+(a2 +b2)x2 +...
    --(+) x y = streamMap


-- Multiplication is a bit trickier. Suppose A = a0 + xA′ and
-- B = b0 + xB′ are two generating functions we wish to multiply. We reason as follows:
-- AB = (a0 + xA′)B = a0B + xA′B
-- = a0(b0 + xB′) + xA′B = a0b0 + x(a0B′ + A′B)
-- That is, the first element of the product AB is the product of the first elements, a0b0;
-- the remainder of the coefficient stream (the part after the x) is formed by
-- multiplying every element in B′ (that is, the tail of B) by a0,
-- and to this adding the result of multiplying A′ (the tail of A) by B.


-- Note that there are a few methods of the Num class I have not told you to implement, such as abs and signum. ghc will complain that you haven’t defined them, but don’t worry about it. We won’t need those methods. (To turn off these warnings you can add
--    {-# OPTIONS_GHC -fno-warn-missing-methods #-}
-- to the top of your file.)
-- If you have implemented the above correctly, you should be able
-- to evaluate things at the ghci prompt such as
--    *Main> x^4
--    *Main> (1 + x)^5
--    *Main> (x^2 + x + 3) * (x - 5)



