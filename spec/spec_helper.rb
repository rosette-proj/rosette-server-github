# encoding: UTF-8

require 'pry-nav'
require 'rack/test'
require 'rosette/server/github'
require 'rosette/server'
require 'rosette/test-helpers'
require 'rspec'

Rosette.logger = NullLogger.new

RSpec.configure do |config|
end
