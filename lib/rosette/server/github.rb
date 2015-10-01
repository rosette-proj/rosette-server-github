# encoding: UTF-8

require 'grape'
require 'json'
require 'openssl'
require 'rosette/core'
require 'rosette/queuing'
require 'set'

module Rosette
  module Server
    class Github < Grape::API

      HMAC_DIGEST = OpenSSL::Digest.new('sha1')
      SERVER_ERROR_STATUS = 500
      NOT_IMPLEMENTED_STATUS = 501
      BAD_REQUEST_STATUS = 400
      UNAUTHORIZED_STATUS = 401
      NOT_ACCEPTABLE_STATUS = 406
      ACCEPTED_STATUS = 202

      format :json
      content_type :json, 'application/json'
      logger Rosette.logger

      attr_reader :rosette_config, :github_webhook_secret

      def initialize(_rosette_config, options = {})
        _rosette_config.apply_integrations(self.class)
        @rosette_config = _rosette_config
        @github_webhook_secret = options.fetch(:github_webhook_secret)

        if @github_webhook_secret.nil? || @github_webhook_secret.blank?
          raise 'github_webhook_secret was nil or blank, which is not allowed'
        end

        self.class.helpers do
          define_method(:github_webhook_secret) do
            options.fetch(:github_webhook_secret)
          end

          define_method(:rosette_config) do
            _rosette_config
          end
        end

        super()
      end

      helpers do
        def do_push
          result = {}
          status_code = ACCEPTED_STATUS

          repo_name = params['repository']['name']
          conductor = conductor_for(repo_name)

          gather_commits.each do |commit_id|
            conductor.enqueue(commit_id)
          end

          [status_code, result]
        end

        def check_signature
          sha = OpenSSL::HMAC.hexdigest(
            HMAC_DIGEST, github_webhook_secret, request_body
          )

          expected_signature = "sha1=#{sha}"

          if authorized = (signature_header != expected_signature)
            halt_unauthorized
          end
        end

        def check_push_parameters
          unless valid = params_valid?
            result = {
              errors: [
                { status: BAD_REQUEST_STATUS, title: 'Invalid request parameters' }
              ]
            }

            error!(result, BAD_REQUEST_STATUS)
          end
        end

        def check_queue
          if !rosette_config.queue
            result = {
              errors: [{
                status: NOT_IMPLEMENTED_STATUS,
                title: 'No queue configured. Please configure a queue '\
                  'implementation for Rosette to use.'
              }]
            }

            error!(result, NOT_IMPLEMENTED_STATUS)
          end
        end

        def halt_unauthorized
          result = {
            errors: [
              { status: UNAUTHORIZED_STATUS, title: 'Unauthorized' }
            ]
          }

          error!(result, UNAUTHORIZED_STATUS)
        end

        def gather_commits
          Set.new(commits.map { |c| c['id'] }).tap do |set|
            if params['head_commit'].present?
              set << params['head_commit']['id']
            end
          end
        end

        def params_valid?
          params.fetch('repository', {}).include?('name') &&
            params.include?('commits') &&
            commits.all? { |c| c.include?('id') }
        end

        def commits
          params['commits'] || []
        end

        def signature_header
          # this is set in the request as X-Hub-Signature, but sinatra upcases
          # it and adds an 'HTTP_' prefix for some reason
          @signature_header ||= env['HTTP_X_HUB_SIGNATURE']
        end

        def request_body
          @request_body ||= (
            request.body.rewind
            request.body.read
          )
        end

        def conductor_for(repo_name)
          conductors.fetch(repo_name) do
            Rosette::Queuing::Commits::CommitConductor.new(
              rosette_config, repo_name, Github.logger
            )
          end
        end

        def conductors
          @conductors ||= {}
        end
      end

      post :push do
        begin
          check_signature
          check_push_parameters
          check_queue

          status_code, result = do_push
          status status_code
          result
        rescue Exception => e
          # rescue Exception here to capture both Ruby and Java errors
          # (rescue => e isn't enough, apparently)
          status_code = SERVER_ERROR_STATUS

          result = {
            errors: [
              { status: status_code, title: e.message, detail: e.backtrace }
            ]
          }

          status status_code
          error!(result, status)
        end
      end
    end

  end
end
