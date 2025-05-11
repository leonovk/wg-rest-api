# frozen_string_literal: true

RSpec.describe Utils::ConfigFileBuilder do
  subject(:build) { described_class.build(config.to_json) }

  context 'when there is dns in the config' do
    let(:config) do
      {
        private_key: '1',
        address: '23.23.23.23',
        address_ipv6: 'a:sd:ds:de',
        dns: '1.1.1.1',
        server_public_key: '2',
        preshared_key: '3',
        allowed_ips: '1.2.3.4',
        persistent_keepalive: 4,
        endpoint: '2.3.4.1'
      }
    end

    let(:expected_result) do
      <<~TEXT
        [Interface]
        PrivateKey = 1
        Address = 23.23.23.23, a:sd:ds:de
        DNS = 1.1.1.1

        [Peer]
        PublicKey = 2
        PresharedKey = 3
        AllowedIPs = 1.2.3.4
        PersistentKeepalive = 4
        Endpoint = 2.3.4.1
      TEXT
    end

    it 'returns the expected result' do
      expect(build).to eq(expected_result)
    end
  end

  context 'when there is no dns in the config' do
    let(:config) do
      {
        private_key: '1',
        address: '23.23.23.23',
        address_ipv6: 'a:sd:ds:de',
        dns: nil,
        server_public_key: '2',
        preshared_key: '3',
        allowed_ips: '1.2.3.4',
        persistent_keepalive: 4,
        endpoint: '2.3.4.1'
      }
    end

    let(:expected_result) do
      <<~TEXT
        [Interface]
        PrivateKey = 1
        Address = 23.23.23.23, a:sd:ds:de

        [Peer]
        PublicKey = 2
        PresharedKey = 3
        AllowedIPs = 1.2.3.4
        PersistentKeepalive = 4
        Endpoint = 2.3.4.1
      TEXT
    end

    it 'returns the expected result' do
      expect(build).to eq(expected_result)
    end
  end
end
