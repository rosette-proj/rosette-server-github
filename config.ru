# This file is meant to be used for testing/development purposes only. To use
# rosette-server-github, most users will want to add it to their instance
# of rosette-server.

require 'rosette/server/github'
require 'rosette/test-helpers'

rosette_config = Rosette.build_config do |config|
  config.use_queue('test')
end

server = Rosette::Server::Github.new(rosette_config, {
  github_webhook_secret: ENV['GITHUB_WEBHOOK_SECRET']
})

run server
