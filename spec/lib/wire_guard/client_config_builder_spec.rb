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

  context 'when are the server starting conditions' do
    let(:configs) do
      {
        'last_id' => 0
      }
    end

    let(:expected_result) do
      {
        id: 1,
        address: '10.8.0.2',
        address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:2',
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

  context 'when there are no clients on the server' do
    let(:configs) do
      {
        'last_id' => 23
      }
    end

    let(:expected_result) do
      {
        id: 24,
        address: '10.8.0.2',
        address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:2',
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
        '1' => {
          'address' => '10.8.0.2',
          'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:2'
        }
      }
    end

    let(:expected_result) do
      {
        id: 2,
        address: '10.8.0.3',
        address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:3',
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
        '1' => {
          'address' => '10.8.0.2',
          'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:2'
        },
        '3' => {
          'address' => '10.8.0.4',
          'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:4'
        }
      }
    end

    let(:expected_result) do
      {
        id: 4,
        address: '10.8.0.3',
        address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:3',
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

  context 'when there is no space for a new IP address' do
    let(:configs) do
      {
        'last_id' => 3,
        '1' => {
          'address' => '10.8.0.2',
          'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:2'
        },
        '3' => {
          'address' => '10.8.0.4',
          'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:4'
        },
        '4' => {
          'address' => '10.8.0.5',
          'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:5'
        },
        '5' => {
          'address' => '10.8.0.6',
          'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:6'
        },
        '6' => {
          'address' => '10.8.0.7',
          'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:7'
        },
        '7' => {
          'address' => '10.8.0.8',
          'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:8'
        }
      }
    end

    it 'causes an error that all IP addresses are taken' do
      expect { build }.to raise_error(Errors::ConnectionLimitExceededError)
    end
  end

  context 'when the user has an old config (edge ​​case that tests backward compatibility)' do
    let(:configs) do
      {
        'last_id' => 3,
        'last_address' => '10.8.0.4',
        '1' => {
          'address' => '10.8.0.2',
          'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:2'
        },
        '3' => {
          'address' => '10.8.0.4',
          'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:4'
        }
      }
    end

    let(:expected_result) do
      {
        id: 4,
        address: '10.8.0.3',
        address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:3',
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
