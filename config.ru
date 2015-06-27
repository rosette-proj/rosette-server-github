# This file is meant to be used for testing/development purposes only. To use
# rosette-integration-github, most users will want to add it as an integration
# in their Rosette config, which will mount it on their instance of
# Rosette::Server.

require 'rosette/server/github'
require 'rosette/test-helpers'

rosette_config = Rosette.build_config do |config|
  config.use_queue('test')
end

server = Rosette::Server::Github.new(rosette_config, {
  github_webhook_secret: ENV['GITHUB_WEBHOOK_SECRET']
})

run server
