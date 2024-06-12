# frozen_string_literal: true

ENV['AUTH_TOKEN'] = '123'

RSpec.describe Application do
  include Rack::Test::Methods

  let(:app) { described_class }
  let(:wg_conf_path) { "#{Settings.wg_path}/wg0.json" }

  before do
    create_conf_file('spec/fixtures/wg0.json')
  end

  after do
    FileUtils.rm_rf(wg_conf_path)
  end

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

  describe 'GET /api/clients' do
    context 'when the request is authorized' do
      before do
        get '/api/clients', nil, { 'Authorization' => 'Bearer 123' }
      end

      it 'returns a successful response' do
        expect(last_response).to be_success
      end
    end

    context 'when the request is not authorized' do
      before do
        get '/api/clients', nil, { 'Authorization' => 'Bearer 1234' }
      end

      it 'returns an unsuccessful response' do
        expect(last_response).not_to be_success
      end
    end
  end
end
