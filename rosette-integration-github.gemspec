$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'rosette/server/github/version'

Gem::Specification.new do |s|
  s.name     = 'rosette-integration-github'
  s.version  = ::Rosette::Server::GITHUB_VERSION
  s.authors  = ['Cameron Dutro']
  s.email    = ['camertron@gmail.com']
  s.homepage = 'http://github.com/camertron'

  s.description = s.summary = 'Github webhook endpoints for the Rosette internationalization platform.'

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true

  s.add_dependency 'grape', '~> 0.9.0'

  s.require_path = 'lib'
  s.files = Dir["{lib,spec}/**/*", "Gemfile", "History.txt", "README.md", "Rakefile", "rosette-server-github.gemspec"]
end
