{-# LANGUAGE CPP #-}

module Main
  ( main
  ) where

import Test.Hspec
import Test.Hspec.Runner

#ifdef MIN_VERSION_hspec_jenkins
import Test.Hspec.Formatters.Jenkins (xmlFormatter)
#endif

import qualified CountLog
import qualified Error
import qualified Reader
import qualified State
import qualified Stream
import qualified Writer
import qualified WordCount


spec :: Spec
spec = do
  describe "CountLog" CountLog.spec
  describe "Error" Error.spec
  describe "Reader" Reader.spec
  describe "State" State.spec
  describe "Stream" Stream.spec
  describe "Writer" Writer.spec
  describe "WordCount" WordCount.spec


main :: IO ()
main = do
  let cfg = defaultConfig
#ifdef MIN_VERSION_hspec_jenkins
        { configFormatter = Just xmlFormatter }
#endif
  hspecWith cfg spec
