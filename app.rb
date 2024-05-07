# frozen_string_literal: true

require 'sinatra'
require 'json'

# Main app class
class Application < Sinatra::Base
  AUTH_TOKEN = "Bearer #{ENV['AUTH_TOKEN']}".freeze

  before do
    content_type :json
    halt 403 unless request.env['HTTP_AUTHORIZATION'] == AUTH_TOKEN
  end

  get '/clients' do
    { client: 'lol' }.to_json
  end
end
