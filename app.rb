# frozen_string_literal: true

require 'sinatra'

# Main app class
class Application < Sinatra::Base
  AUTH_TOKEN = "Bearer #{ENV.fetch('AUTH_TOKEN', nil)}".freeze

  before do
    content_type :json

    pass if request.path == '/healthz'

    halt 403 unless request.env['HTTP_AUTHORIZATION'] == AUTH_TOKEN

    @controller = ClientsController.new
  end

  get '/clients' do
    controller.index
  end

  get '/clients/:id' do
    controller.show(params['id'])
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

  get '/healthz' do
    {
      status: 'ok',
      version: File.read('VERSION').gsub('v', '')
    }.to_json
  end

  private

  attr_reader :controller

  def request_body
    JSON.parse(request.body.read)
  rescue JSON::ParserError
    {}
  end
end
