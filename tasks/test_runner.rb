#!/usr/bin/env ruby

TEST_ROOT = File.expand_path('..', File.dirname(__FILE__))
Dir.chdir(TEST_ROOT)
$: << 'libs'

require 'test/unit'

Test::Unit::AutoRunner.run(true, './tests')
