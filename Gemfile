source "https://rubygems.org"

gemspec

ruby '2.0.0', engine: 'jruby', engine_version: '1.7.15'

gem 'rosette-core', github: 'rosette-proj/rosette-core'
gem 'rosette-server', github: 'rosette-proj/rosette-server'

group :development, :test do
  gem 'expert', '~> 1.0.0'
  gem 'rosette-test-helpers', github: 'rosette-proj/rosette-test-helpers'
  gem 'pry-nav'
  gem 'rake'
end

group :test do
  gem 'rack-test'
  gem 'rspec'
end
