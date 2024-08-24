# frozen_string_literal: true

require 'sinatra'
require 'sinatra/contrib'
require_relative 'config/sentry'

# Main app class
class Application < Sinatra::Base
  # NOTE: Сonnect sentry only if there is a special setting
  use Sentry::Rack::CaptureExceptions if sentry?
  register Sinatra::Namespace

  AUTH_TOKEN = Settings.auth_token
  AUTH_DIGEST_TOKEN = Settings.auth_digest_token

  namespace '/api' do # rubocop:disable Metrics/BlockLength
    before do
      content_type :json

      authorize_resource

      @controller = ClientsController.new
    end

    get '/clients' do
      controller.index
    end

    get '/clients/:id' do
      config = controller.show(params['id'])
      case params['format']
      when 'qr'
        content_type 'image/png'

        send_file Utils::QrCodeBuilder.build(config)
      when 'conf'
        content_type 'text/plain'

        Utils::ConfigFileBuilder.build(config)
      else
        config
      end
    rescue Errors::ConfigNotFoundError
      halt 404
    end

    delete '/clients/:id' do
      controller.destroy(params['id'])
    rescue Errors::ConfigNotFoundError
      halt 404
    end

    patch '/clients/:id' do
      controller.update(params['id'], request_body)
    rescue Errors::ConfigNotFoundError
      halt 404
    rescue JSON::Schema::ValidationError => e
      halt 400, { error: e }.to_json
    end

    post '/clients' do
      status 201

      controller.create(params)
    end
  end

  get '/healthz' do
    {
      status: :ok,
      version: instance_versions
    }.to_json
  end

  private

  attr_reader :controller

  def authorize_resource
    token = request.env['HTTP_AUTHORIZATION']
    halt 403 unless token

    if AUTH_DIGEST_TOKEN
      halt 403 unless Digest::SHA256.hexdigest(token[7..]) == AUTH_DIGEST_TOKEN
    else
      halt 403 unless token[7..] == AUTH_TOKEN
    end
  end

  def instance_versions
    File.read('VERSION').gsub('v', '')
  end

  def request_body
    JSON.parse(request.body.read)
  rescue JSON::ParserError
    {}
  end
end
