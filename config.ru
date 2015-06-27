# This file is meant to be used for testing/development purposes only. To use
# rosette-integration-github, most users will want to add it as an integration
# in their Rosette config, which will mount it on their instance of
# Rosette::Server.

require 'rosette/data_stores'
require 'rosette/integrations/github_integration'
require 'rosette/queuing'
require 'rosette/server'
require 'rosette/test-helpers'

app_class = Rosette::Integrations::GithubIntegration::Application

Rosette::Server::V1.set_configuration(
  Rosette.build_config do |config|
    config.use_queue('test')
  end
)

integration = Rosette::Integrations::GithubIntegration.configure do |configurator|
  configurator.set_github_webhook_secret(ENV['GITHUB_WEBHOOK_SECRET'])
end

app_class.integration_config = integration.configuration
run app_class
