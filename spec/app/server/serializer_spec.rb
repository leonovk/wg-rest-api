# frozen_string_literal: true

RSpec.describe Server::Serializer do
  describe '#serialize' do
    subject(:serialize) { described_class.serialize(JSON.parse(File.read('spec/fixtures/wg0.json'))) }

    let(:expected_result) do
      {
        'server' => { 'private_key' => '6Mlqg+1Umojm7a4VvgIi+YMp4oPrWNnZ5HLRFu4my2w=',
                      'public_key' => 'uygGKpQt7gOwrP+bqkiXytafHiM+XqFGc0jtZVJ5bnw=',
                      'address' => '10.8.0.1',
                      'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:1' },
        'clients_count' => 3,
        'available_clients_count' => 6,
        'dns' => '1.1.1.1',
        'host' => '2.2.2.2',
        'allowed_ips' => '0.0.0.0/0, ::/0',
        'persistent_keepalive' => 0,
        'port' => '51820',
        'connecting_client_limit' => '29'
      }
    end

    it 'serializes one config' do
      expect(JSON.parse(serialize)).to eq(expected_result)
    end
  end
end
