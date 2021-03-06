module WriterModule where

import Control.Applicative
import Data.Monoid

-- What's going on?

-- I have a "Categorizer - with Reason" :: (a, b)
-- It is not quite a Decider, because a decision seems like a fork in the road,
-- and there are no Forks on the Haskell Road (with exception to ForkIO)

-- The Reason is historical. It has gone through a series of mutations.

-- I have an "ApplyLog" :: call it this for now, until I can give it a better name
-- It simply, categorizes x, and merges it with the history of reasons

-- Or, perhaps the following is True... ?
-- Because, my past is of type Integer (antes)
-- and my future, is of type Bool (despues)



applyLog' :: (a, [c]) -> (a -> (b, [c])) -> (b, [c])
applyLog' = undefined


-- K, I need to pull tho inner string out and join it with the second
applyLog :: (Int, [Char]) -> (Int -> (Bool, [Char])) -> (Bool, [Char])
applyLog (v, log) df = let (y, log') = df v in (y, log ++ log')

-- Remember how the let expression looks:
--      pattern = let intermediate = source in target


-- OK. Here is a new problem
-- A function is evaluated
-- I *know* that the function returns a tuple
-- I want something inside that tuple
-- I'm pretty sure that I can pattern match on it
-- I'm thinking of using where statement with an @pat something
-- But mostly probably what I really need is the let clause
-- that I don't really understand how to use



-- So, there is a decision function somewhere around here

-- [?] Something that I am yet to understand.
-- And when can I use the actual type?
-- This is what I would like to do:
-- categorizer :: a -> (b, [Char])
-- but, now I'm going to resort to
-- categorizer :: Int -> (Bool, [Char])

categorizer :: Int -> (Bool, [Char])
categorizer x
    | x < 9     =  (False, "less than")
    | otherwise =  (True, "greater than")

categorizer'' :: Int -> (Bool, Thneed)
categorizer'' x
    | x < 9     =  (False, Thneed "less than")
    | otherwise =  (True, Thneed "greater than")



-- Ok cool
-- What am I going to do with Monoids now?

-- Monoids is about joining things
-- I can declare some thing, and then I can declare that it is joinable

data Thneed = Thneed String
    deriving Show

-- OK: Now I want to make this Thneed composable

instance Monoid Thneed where
    mempty = Thneed ""
    (Thneed x) `mappend` (Thneed y) = Thneed (x ++ y)


someThneed = Thneed "Something that you need"


-- The first step of generalizing
--applyLog'' :: (Int, Thneed) -> (Int -> (Bool, Thneed)) -> (Bool, Thneed)
--applyLog'' (v, log) df = let (y, log') = df v in (y, log `mappend` log')

-- I think that I can generalize it even more
--applyLog'' :: Monoid c => (Int, c) -> (Int -> (Bool, c)) -> (Bool, c)
--applyLog'' (v, log) df = let (y, log') = df v in (y, log `mappend` log')

-- Even further generalization
applyLog''' :: Monoid c => (a, c) -> (a -> (b, c)) -> (b, c)
applyLog''' (v, log) df = let (y, log') = df v in (y, log `mappend` log')



-- So, in brief, what do I do?
-- I was apply ++ on a type
-- I realized that it was a join
-- Made it into an instance of the Monoid type class
-- Replaced the function declaration of it, with a type variable
-- and made that into an instance of a Monoid


-- Remember: The Monoid typeclass has laws
-- Law 1: idenity
-- Law 2: Association




-- THE WRITER TYPE

-- There is a type that looks like: Writer w a
-- Something just like Maybe x

-- it's definition looks like:

newtype Writer w a = Writer { runWriter :: (a, w) }
    deriving Show

newtype WriterPlain w a = WriterPlain (a, w)
    deriving Show

-- I've seen this before: the function inside a type
-- Reminds me of the runParser

someWriter = Writer (3, "hello bob")
plainWriter = WriterPlain (3, "hello bob")

direct_unboxing = runWriter someWriter
convoluted_unboxing = let (WriterPlain x) = plainWriter in x


-- Writing a functor instance for the Writer

instance Functor (Writer w) where
    fmap f (Writer (x, v)) = Writer (f x, v)


-- Writing an applicative instance for the Writer

instance (Monoid w) => Applicative (Writer w) where
    pure x = Writer (x, mempty)
    (Writer (f, v)) <*> (Writer (x, v')) = (Writer (f x, v `mappend` v'))



-- A Monad instance is exported for it





--test = categorizer 7
test = applyLog''' (7, Thneed "this is the past") categorizer''


main :: IO ()
main = undefined

