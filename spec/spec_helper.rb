# encoding: UTF-8

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'expert'
Expert.environment.require_all

require 'pry-nav'
require 'rack/test'
require 'rosette/server/github'
require 'rosette/server'
require 'rosette/test-helpers'
require 'rspec'

Rosette.logger = NullLogger.new

RSpec.configure do |config|
end
