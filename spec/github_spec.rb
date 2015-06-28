# encoding: UTF-8

require 'spec_helper'

include Rosette::Server

describe Github do
  include Rack::Test::Methods

  let(:webhook_secret) { 'abc123' }
  let(:fixture_dir) { File.expand_path('../fixtures', __FILE__) }

  let(:rosette_config) do
    Rosette.build_config do |config|
      config.use_queue('test')
    end
  end

  let(:queue) { rosette_config.queue }

  let(:server) do
    Rosette::Server::Github.new(rosette_config, {
      github_webhook_secret: webhook_secret
    })
  end

  before(:each) do
    header 'Content-Type', 'application/json'
  end

  def app
    server
  end

  describe '#initialize' do
    it 'raises an error on initialize if the secret is blank' do
      expect do
        Rosette::Server::Github.new(rosette_config, github_webhook_secret: nil)
      end.to raise_error(
        /github_webhook_secret was nil or blank/
      )
    end
  end

  describe 'POST /push.json' do
    let(:endpoint) { '/push.json' }
    let(:response) { JSON.parse(last_response.body) }
    let(:status) { last_response.status }
    let(:body) { File.read(File.join(fixture_dir, 'push_request.json')) }

    before(:each) do
      header 'X-Github-Event', 'push'
      header 'X-Hub-Signature', "sha1=#{signature}"
    end

    context 'with the wrong signature' do
      let(:webhook_secret) { 'foobar' }
      let(:signature) { 'wrongwrong' }

      it 'responds with an unauthorized status' do
        post endpoint, body
        expect(status).to eq(401)
        expect(response['errors'].first['status']).to eq(401)
        expect(response['errors'].first['title']).to eq('Unauthorized')
      end
    end

    context 'with the correct signature' do
      let(:signature) do
        digest = OpenSSL::Digest.new('sha1')
        OpenSSL::HMAC.hexdigest(digest, webhook_secret, body)
      end

      it 'responds with an accepted status and enqueues the commit' do
        expect { post(endpoint, body) }.to change { queue.class.list.size }.by(1)
        expect(status).to eq(202)
      end

      context 'with multiple commits in the push' do
        let(:body) do
          File.read(File.join(fixture_dir, 'push_request_with_commits.json'))
        end

        it 'responds with an accepted status and enqueues both commits' do
          expect { post(endpoint, body) }.to change { queue.class.list.size }.by(2)
          expect(status).to eq(202)
        end
      end

      context 'with duplicate commits in the push' do
        let(:body) do
          File.read(File.join(fixture_dir, 'duplicate_commits.json'))
        end

        it 'responds with an accepted status and enqueues the commit once' do
          expect { post(endpoint, body) }.to change { queue.class.list.size }.by(1)
          expect(status).to eq(202)
        end
      end

      context 'with an incorrect set of parameters' do
        let(:body) do
          File.read(File.join(fixture_dir, 'missing_required_params.json'))
        end

        it 'responds with a bad request status' do
          post endpoint, body
          expect(status).to eq(400)
          expect(response['errors'].first['status']).to eq(400)
          expect(response['errors'].first['title']).to eq(
            'Invalid request parameters'
          )
        end
      end

      context "with no queue configured" do
        before(:each) do
          allow(rosette_config).to receive(:queue).and_return(nil)
        end

        it 'responds with a not implemented status' do
          post endpoint, body
          expect(status).to eq(501)
          expect(response['errors'].first['status']).to eq(501)
          expect(response['errors'].first['title']).to(
            include('No queue configured.')
          )
        end
      end
    end
  end
end
