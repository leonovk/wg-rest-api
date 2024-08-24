# frozen_string_literal: true

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
    before do
      allow(WireGuard::StatGenerator).to receive_messages(show: nil)
    end

    context 'when the request is authorized' do
      before do
        header('Authorization', 'Bearer 123-Ab')
        get '/api/clients'
      end

      it 'returns a successful response' do
        expect(last_response.successful?).to be(true)
      end
    end

    context 'when the request is authorized but an encrypted token is set' do
      before do
        allow(Settings).to receive(:auth_digest_token)
          .and_return('8c24220738721bb1a0ad0607527293c16d0d44f2a645980efc271a0a03006d4c')
        header('Authorization', 'Bearer 123-Ab')
        get '/api/clients'
      end

      it 'returns a successful response' do
        expect(last_response.successful?).to be(true)
      end
    end

    context 'when no authorization header was passed at all' do
      before do
        get '/api/clients'
      end

      it 'returns an unsuccessful response' do
        expect(last_response.successful?).to be(false)
        expect(last_response.status).to be(403)
      end
    end

    context 'when the request is not authorized' do
      before do
        header('Authorization', 'Bearer 123-ab')
        get '/api/clients'
      end

      it 'returns an unsuccessful response' do
        expect(last_response.successful?).to be(false)
        expect(last_response.status).to be(403)
      end
    end
  end
end
