{- CIS 194 HW 11
   due Monday, 8 April
-}

module SExpr where

import AParser
import Control.Applicative

import Data.Char (isSpace, isAlpha, isAlphaNum)

------------------------------------------------------------
--  1. Parsing repetitions
------------------------------------------------------------

-- Hint: To parse one or more occurrences of p,
-- run p once and then parse zero or more occurrences of p.
-- To parse zero or more occurrences of p, try parsing one or more;
-- if that fails, return the empty list.


zeroOrMore :: Parser a -> Parser [a]
zeroOrMore p = oneOrMore p <|> pure []

oneOrMore :: Parser a -> Parser [a]
oneOrMore p = (:) <$> p <*> zeroOrMore p


------------------------------------------------------------
--  2. Utilities
------------------------------------------------------------

-- First, spaces should parse a consecutive list of zero or more whitespace characters
-- (use the isSpace function from the standard Data.Char module).

spaces :: Parser String
spaces = zeroOrMore (satisfy isSpace)

-- Next, ident should parse an identifier,
-- which for our purposes will be an alphabetic character (use isAlpha) followed by zero or more alphanumeric characters (use isAlphaNum).
-- In other words, an identifier can be any nonempty sequence of letters and digits,
-- except that it may not start with a digit.

ident :: Parser String
ident = (:) <$> (satisfy isAlpha) <*> zeroOrMore (satisfy isAlphaNum)



------------------------------------------------------------
--  3. Parsing S-expressions
------------------------------------------------------------

-- An "identifier" is represented as just a String; however, only
-- those Strings consisting of a letter followed by any number of
-- letters and digits are valid identifiers.
type Ident = String

-- An "atom" is either an integer value or an identifier.
data Atom = N Integer | I Ident
  deriving Show

-- An S-expression is either an atom, or a list of S-expressions.
data SExpr = A Atom
           | Comb [SExpr]
  deriving Show



sexpr_1 = "5"
sexpr_2 = "foo3"
sexpr_3 = "(bar (foo) 3 5 874)"
sexpr_4 = "(((lambda x (lambda y (plus x y))) 3) 5)"
sexpr_5 = "(   lots  of   (  spaces   in  )  this ( one ) )"


parseAtom :: Parser Atom
parseAtom = (N <$> posInt) <|> (I <$> ident)

parseCollection :: Parser [SExpr]
parseCollection = (char '(' *> oneOrMore parseSExpr) <* char ')'

parseSpaces :: Parser [Char]
parseSpaces = zeroOrMore $ satisfy isSpace

parseSExpr :: Parser SExpr
parseSExpr = (parseSpaces *> ((A <$> parseAtom) <|> (Comb <$> parseCollection))) <* parseSpaces









-- Being practical
parseBranch :: Parser Integer
parseBranch = oneOrMore (satisfy isAlpha <|> char '-') *> posInt

example = "ipiyasena-multi-tenant-support-7050 13030:98fe3563246c (inactive)"

-- starts with a literal
-- looks like a timestamp
-- the timestamp has milliseconds
-- then some sort of UUID
-- then something unique
-- finally a .request
icap_example = "icap_1353374505.47060_b9cf50e33a564e538f80180a82b420dd_HVACFz.request"


-- TODO: How can I make parsing strings better
parseLiteral :: Parser String
parseLiteral = (\x y w z -> [x, y, w, z]) <$> char 'i' <*> char 'c' <*> char 'a' <*> char 'p'

parseTimestamp :: Parser String
parseTimestamp = (\x y z -> show x ++ [y] ++ show z) <$> posInt <*> (char '.') <*> posInt

-- TODO: How do I get 32 chars?
parseHash :: Parser String
parseHash = oneOrMore (satisfy isAlphaNum)

parseUnique :: Parser String
parseUnique = oneOrMore (satisfy isAlphaNum)

-- TODO: How do I discard the first?
parseICAP :: Parser ICAP
parseICAP = ICAP <$> parseLiteral <* char '_' <*> parseTimestamp <* char '_' <*> parseHash <* char '_' <*> parseUnique


type Timestamp = String
type Hash = String
type Unique = String

data ICAP = ICAP String Timestamp Hash Unique
    deriving Show




















