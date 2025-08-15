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

    delete '/clients/inactive' do
      controller.destroy_inactive(params['days'] || 5)
    end
  end

  delete '/deleteinactiveusers' do
    content_type :json
    
    # Simple auth check
    token = request.env['HTTP_AUTHORIZATION']
    halt 403 unless token
    
    if AUTH_DIGEST_TOKEN
      halt 403 unless Digest::SHA256.hexdigest(token[7..]) == AUTH_DIGEST_TOKEN
    else
      halt 403 unless token[7..] == AUTH_TOKEN
    end
    
    days = (params['days'] || 5).to_i
    
    begin
      # Create a controller instance to access WireGuard functionality
      controller = ClientsController.new
      
      # Get all clients
      all_clients = JSON.parse(controller.index)
      deleted_clients = []
      
      # Calculate threshold date
      inactive_threshold = Time.now - (days * 24 * 60 * 60)
      
      all_clients.each do |client|
        next unless client['last_online']
        
        begin
          last_online = Time.parse(client['last_online'])
          
          if last_online < inactive_threshold
            # Delete this client
            begin
              controller.destroy(client['id'].to_s)
              deleted_clients << {
                id: client['id'],
                address: client['address'],
                last_online: client['last_online']
              }
            rescue StandardError => e
              # Skip if deletion fails
              next
            end
          end
        rescue ArgumentError
          # Skip clients with invalid date format
          next
        end
      end
      
      {
        deleted_count: deleted_clients.size,
        deleted_clients: deleted_clients,
        days_checked: days,
        threshold_date: inactive_threshold.strftime('%Y-%m-%d %H:%M:%S UTC')
      }.to_json
      
    rescue StandardError => e
      {
        deleted_count: 0,
        deleted_clients: [],
        error: "Unable to process inactive clients: #{e.message}",
        days_checked: days
      }.to_json
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
    File.read('VERSION').gsub('v', '').gsub("\n", '')
  end

  def request_body
    JSON.parse(request.body.read)
  rescue JSON::ParserError
    {}
  end
end
