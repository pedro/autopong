require "rubygems"
require "bundler"
Bundler.require

require "minitest/spec"
require "minitest/autorun"
require "purdytest"

require File.expand_path("../../lib/autopong", __FILE__)

include Autopong
