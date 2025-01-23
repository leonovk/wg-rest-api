# frozen_string_literal: true

RSpec.describe WireGuard::ClientConfigBuilder do
  subject(:build) { described_class.new(configs, params).config }

  before do
    allow(WireGuard::KeyGenerator).to receive_messages(wg_genkey: 'wg_genkey', wg_pubkey: 'wg_pubkey',
                                                       wg_genpsk: 'wg_genpsk')
  end

  let(:params) do
    {
      lol: 'kek'
    }
  end

  context 'when there are no clients on the server' do
    let(:configs) do
      {
        'last_id' => 23,
        'last_address' => '10.8.0.255'
      }
    end

    let(:expected_result) do
      {
        id: 24,
        address: '10.8.1.0',
        private_key: 'wg_genkey',
        public_key: 'wg_pubkey',
        preshared_key: 'wg_genpsk',
        enable: true,
        data: {
          lol: 'kek'
        }
      }
    end

    it 'creates the correct config' do
      expect(build).to eq(expected_result)
    end
  end

  context 'when there is 1 client on the server and the last IP corresponds to it' do
    let(:configs) do
      {
        'last_id' => 1,
        'last_address' => '10.8.0.2',
        '1' => {
          'address' => '10.8.0.2'
        }
      }
    end

    let(:expected_result) do
      {
        id: 2,
        address: '10.8.0.3',
        private_key: 'wg_genkey',
        public_key: 'wg_pubkey',
        preshared_key: 'wg_genpsk',
        enable: true,
        data: {
          lol: 'kek'
        }
      }
    end

    it 'creates the correct config' do
      expect(build).to eq(expected_result)
    end
  end

  context 'when there is 1 client on the server, but the last IP does not match it' do
    let(:configs) do
      {
        'last_id' => 2,
        'last_address' => '10.8.0.3',
        '1' => {
          'address' => '10.8.0.2'
        }
      }
    end

    let(:expected_result) do
      {
        id: 3,
        address: '10.8.0.3',
        private_key: 'wg_genkey',
        public_key: 'wg_pubkey',
        preshared_key: 'wg_genpsk',
        enable: true,
        data: {
          lol: 'kek'
        }
      }
    end

    it 'creates the correct config' do
      expect(build).to eq(expected_result)
    end
  end

  context 'when there are several clients on the server, but there are free IPs between them' do
    let(:configs) do
      {
        'last_id' => 3,
        'last_address' => '10.8.0.4',
        '1' => {
          'address' => '10.8.0.2'
        },
        '3' => {
          'address' => '10.8.0.4'
        }
      }
    end

    let(:expected_result) do
      {
        id: 4,
        address: '10.8.0.3',
        private_key: 'wg_genkey',
        public_key: 'wg_pubkey',
        preshared_key: 'wg_genpsk',
        enable: true,
        data: {
          lol: 'kek'
        }
      }
    end

    it 'creates the correct config' do
      expect(build).to eq(expected_result)
    end
  end
end
