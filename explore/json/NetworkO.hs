--import Network          (PortID(PortNumber), withSocketsDo, listenOn, accept)
import Network

import Network.Socket   (Socket, SocketOption(KeepAlive), close, setSocketOption)

--import System.IO        (Handle, hPutStrLn, hGetLine, hFlush, hClose)
import System.IO
import Aesyon (reMapNuggets)

import System.Log.Logger
import System.Log.Handler.Syslog
import System.Log.Handler.Simple
import System.Log.Handler (setFormatter)
import System.Log.Formatter


host = "127.0.0.100"
port   = 62005


main :: IO ()
main = withSocketsDo $ do

    debugM "MyApp.Component"  "This is a debug message -- never to be seen"
    warningM "MyApp.Component2" "Something Bad is about to happen."

    -- Copy everything to syslog from here on out.
    s <- openlog "SyslogStuff" [PID] USER DEBUG
    updateGlobalLogger rootLoggerName (addHandler s)

    errorM "MyApp.Component" "This is going to stderr and syslog."


    putStrLn "Going to accept from a network connection..."
    --sock <- listenOn $ PortNumber port
    putStrLn host
    putStrLn (show port)


    sock <- listenOn (PortNumber (fromIntegral port))

    -- Mark the socket for keep-alive handling since it may be idle
    -- for long periods of time
    setSocketOption sock KeepAlive 1

    putStrLn "Awaiting connection."
    (h,host,port) <- accept sock
    putStrLn $ "Received connection from " ++ host ++ ":" ++ show port
    hSetBuffering h LineBuffering
    --h <- connectTo host (PortNumber (fromIntegral port))
    --hSetBuffering h NoBuffering
    --sockHandler sock
    putStrLn "Listening"
    listen h


listen :: Handle -> IO ()
listen h = forever $ do
    s <- hGetLine h
    putStrLn s
    warningM "MyApp.Component2" $ "Got request: " ++  s
    --hPutStrLn h getEncodedNuggets
    nuggets <- reMapNuggets s
    hPutStrLn h nuggets
  where
    forever a = do a; forever a
