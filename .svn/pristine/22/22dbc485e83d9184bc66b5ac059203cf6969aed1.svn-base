# coding: utf8
TOPDIR = File.join(File.dirname(__FILE__),'..','..')
$LOAD_PATH.unshift TOPDIR unless $LOADED
$LOADED = true

require 'rubygems'
require 'bundler/setup'
# if you donot want to require gems by default, please comment here.
Bundler.require :default

require 'att'
require 'att/base'

require 'att/test_unit/test_helper'


ATT::ConfigureManager.root = TOPDIR

require 'att/initialize'

use_fixture

$all_tests = []
Dir.chdir TOPDIR do
$all_tests += Dir["keywords/unittests/**/test_*.rb"]
end