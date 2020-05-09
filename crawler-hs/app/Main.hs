{-# LANGUAGE OverloadedStrings #-}
module Main where

import Data.Ini


data Config = Config {apikey :: String, outputFolder :: String}
    deriving Show


loadConfig :: IO Config
loadConfig = do
    Right result <- readIniFile "production.config"
    apikey <- (result >>= (lookupValue "Gdanskie Wody" "apikey"))
    folder <- (result >>= (lookupValue "Gdanskie Wody" "output-folder"))
    return (Config apikey folder)


main :: IO ()
main = do
    config <- loadConfig
    putStrLn (show config)
    return ()

