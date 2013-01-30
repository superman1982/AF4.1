# coding: utf8
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'..','..') unless $LOADED
$LOADED = true
require 'keywords/unittests/setup'

$all_tests.each { |test| require test }
