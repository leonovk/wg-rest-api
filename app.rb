# frozen_string_literal: true

require 'sinatra'
require 'json'

# Main app class
class Application < Sinatra::Base
  AUTH_TOKEN = "Bearer #{ENV.fetch('AUTH_TOKEN', nil)}".freeze

  before do
    content_type :json

    pass if request.path == '/healthz'

    halt 403 unless request.env['HTTP_AUTHORIZATION'] == AUTH_TOKEN
  end

  get '/clients' do
    ClientsController.new.index
  end

  get '/clients/:id' do
    ClientsController.new.show(params['id'])
  rescue Errors::ConfigNotFoundError
    halt 404
  end

  delete '/clients/:id' do
    ClientsController.new.destroy(params['id'])
  rescue Errors::ConfigNotFoundError
    halt 404
  end

  post '/clients' do
    status 201
    ClientsController.new.create(params)
  end

  get '/healthz' do
    {
      status: 'ok',
      version: File.read('VERSION')
    }.to_json
  end
end
