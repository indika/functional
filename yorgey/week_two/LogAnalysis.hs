{-# OPTIONS_GHC -Wall #-}
module LogAnalysis where

import Log



-- parses and indivdiual line from the log file
--
-- parseMessage "E 2 562 help help" == LogMessage (Error 2) 562 "help help"
-- parseMessage "I 29 la la la" == LogMessage Info 29 "la la la"
-- parseMessage "This is not in the right format" == Unknown "This is not in the right format"



--makeWords :: String -> [String]
--makeWords x = words x

--parseRest :: [String] -> (TimeStamp, String)
--parseRest (x:xs) = (read x :: Int, unwords xs)


-- What are all things wrong with this?
-- If there is no timestamp, or it cannot be parsed then it will fail
-- If there is no text afterwards, then it will fail
getLogMessage :: [String] -> LogMessage
getLogMessage [] = Unknown ""
getLogMessage (x:y:ys)
    | x == "I" = LogMessage Info (timestamp (y:ys)) (text (y:ys))
    | x == "W" = LogMessage Warning (timestamp (y:ys)) (text (y:ys))
    | x == "E" = LogMessage (Error (severity y)) (timestamp ys) (text ys)
    | otherwise = Unknown (unwords (x:y:ys))
    where timestamp xs = read (head xs) :: Int
          text xs = unwords (tail xs)
          severity s = read s :: Int
getLogMessage x = Unknown (unwords x)

-- How do I integrate this function with the one above
parseMessage :: String -> LogMessage
parseMessage x = getLogMessage (words x)


-- Can parse the entire file
parse :: String -> [LogMessage]
parse x = map parseMessage (lines x)

--
--testParse parse 10 "error.log"
--testParse parse 100 "error.log"
--testParse parse 5523 "error.log"


message_one :: LogMessage
message_one = LogMessage Info 10  "This is message one"

message_two :: LogMessage
message_two = LogMessage Info 20  "This is message two"

message_three :: LogMessage
message_three = LogMessage Info 5  "This is message three"


a_tree = Node Leaf message_one Leaf

some_logs = testParse parse 5 "error.log"

-- which inserts a new LogMessage into an existing MessageTree, producing a new MessageTree.
-- insert may assume that it is given a sorted MessageTree,
-- and must produce a new sorted MessageTree containing the new LogMessage
-- in addition to the contents of the original MessageTree.
-- However, note that if insert is given a LogMessage which is Unknown,
-- it should return the MessageTree unchanged.





-- These functions replaces the current tree with a new one
insertLeft :: LogMessage -> MessageTree -> MessageTree
insertLeft _ Leaf = error "Cannot insert left into a leaf"
insertLeft incoming (Node _ m right) = Node (Node Leaf incoming Leaf) m right

insertRight :: LogMessage -> MessageTree -> MessageTree
insertRight _ Leaf = error "Cannot insert right into a leaf"
insertRight incoming (Node left m _) = Node left m (Node Leaf incoming Leaf)


insert :: LogMessage -> MessageTree -> MessageTree
insert (Unknown _) tree = tree
insert (LogMessage m1 x text1) Leaf = Node Leaf (LogMessage m1 x text1) Leaf
insert (LogMessage m1 x text1) (Node left (LogMessage mtype node_t text ) right)
    | (node_t >= x) && (left == Leaf) = insertLeft (LogMessage m1 x text1) (Node left (LogMessage mtype node_t text ) right)
    | (node_t >= x) = insert (LogMessage m1 x text1) (left)
    | (node_t < x) && (right == Leaf) = insertRight (LogMessage m1 x text1) (Node left (LogMessage mtype node_t text ) right)
    | (node_t < x) = insert (LogMessage m1 x text1) (right)



-- build a message tree
-- begins with a leaf
build ::  [LogMessage] -> MessageTree
build x = insert (head x) Leaf



