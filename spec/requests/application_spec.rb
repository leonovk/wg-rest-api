# frozen_string_literal: true

RSpec.describe Application do
  include Rack::Test::Methods

  let(:app) { described_class }

  describe 'GET /healthz' do
    before do
      get '/healthz'
    end

    let(:expected_body) do
      {
        status: 'ok',
        version: File.read('VERSION').gsub('v', '')
      }
    end

    it 'returns the server state' do
      expect(last_response.body).to eq(expected_body.to_json)
    end
  end
end
