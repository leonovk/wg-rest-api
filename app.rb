# frozen_string_literal: true

require 'sinatra'
require 'sinatra/contrib'
require_relative 'config/sentry'

# Main app class
class Application < Sinatra::Base
  # NOTE: Сonnect sentry only if there is a special setting
  use Sentry::Rack::CaptureExceptions if sentry?
  register Sinatra::Namespace
  set :host_authorization, { permitted_hosts: [] }
  enable :sessions
  set :session_secret, Settings.auth_digest_token

  AUTH_TOKEN = Settings.auth_token
  AUTH_DIGEST_TOKEN = Settings.auth_digest_token
  ADMIN_PANEL_PASSWORD = Settings.admin_panel_password

  namespace '/api' do # rubocop:disable Metrics/BlockLength
    before do
      content_type :json

      authorize_resource

      @controller = Api::Clients::Controller.new
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
    rescue Errors::ConfigNotFoundError => e
      halt 404, { error: e.message }.to_json
    end

    delete '/clients/:id' do
      controller.destroy(params['id'])
    rescue Errors::ConfigNotFoundError => e
      halt 404, { error: e.message }.to_json
    end

    patch '/clients/:id' do
      controller.update(params['id'], request_body)
    rescue Errors::ConfigNotFoundError => e
      halt 404, { error: e.message }.to_json
    rescue JSON::Schema::ValidationError => e
      halt 400, { error: e }.to_json
    end

    post '/clients' do
      status 201

      controller.create(request_body)
    end

    get '/server' do
      Api::Server::Controller.new.show
    end
  end

  namespace '/admin' do
    set :views, "#{settings.root}/app/admin/views"

    before do
      redirect to('/admin/') if !admin_authorized? and request.path != '/admin/' and request.path != '/admin/login'

      @controller = Admin::Clients::Controller.new
    end

    post '/login' do
      if params['password'] == ADMIN_PANEL_PASSWORD
        session[:admin_password] = params['password']
        redirect to('/admin/clients')
      else
        redirect to('/admin/')
      end
    end

    get '/' do
      erb :login
    end

    get '/clients' do
      erb :clients, locals: { clients: controller.clients }
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

  def admin_authorized?
    return false unless AUTH_DIGEST_TOKEN
    return false if ADMIN_PANEL_PASSWORD.empty?

    session[:admin_password] == ADMIN_PANEL_PASSWORD
  end

  def authorize_resource
    token = request.env['HTTP_AUTHORIZATION']
    halt 403 if token.nil? || token.size < 8

    if AUTH_DIGEST_TOKEN
      halt 403 unless Digest::SHA256.hexdigest(token[7..]) == AUTH_DIGEST_TOKEN
    else
      halt 403 unless token[7..] == AUTH_TOKEN
    end
  end

  def instance_versions
    File.read('VERSION').gsub('v', '').gsub("\n", '')
  end

  def request_body
    JSON.parse(request.body.read)
  rescue JSON::ParserError
    {}
  end
end
