# frozen_string_literal: true

RSpec.describe ClientsSerializer do
  before do
    allow(WireGuard::StatGenerator).to receive_messages(show: '')
  end

  let(:key) { '4' }

  describe '#serialize' do
    subject(:serialize) { described_class.serialize(config, key) }

    let(:config) do
      {
        id: 1,
        address: '10.8.0.2',
        private_key: '1',
        public_key: '2',
        preshared_key: '3',
        enable: true,
        data: {}
      }
    end

    let(:expected_result) do
      {
        id: 1,
        server_public_key: '4',
        address: '10.8.0.2/24',
        private_key: '1',
        public_key: '2',
        preshared_key: '3',
        enable: true,
        allowed_ips: '0.0.0.0/0, ::/0',
        dns: '1.1.1.1',
        persistent_keepalive: 0,
        endpoint: '2.2.2.2:51820',
        last_online: nil,
        trafik: nil,
        data: {}
      }.to_json
    end

    it 'serializes one config' do
      expect(serialize).to eq(expected_result)
    end
  end

  describe '#each_serialize' do
    subject(:serialize) { described_class.each_serialize(config, key) }

    let(:config) do
      {
        '1' => {
          id: 1,
          address: '10.8.0.2',
          private_key: '1',
          public_key: '2',
          preshared_key: '3',
          enable: true,
          data: {}
        },
        '2' => {
          id: 2,
          address: '10.8.0.3',
          private_key: '1',
          public_key: '2',
          preshared_key: '3',
          enable: false,
          data: {}
        }
      }
    end

    let(:expected_result) do
      [
        {
          id: 1,
          server_public_key: '4',
          address: '10.8.0.2/24',
          private_key: '1',
          public_key: '2',
          preshared_key: '3',
          enable: true,
          allowed_ips: '0.0.0.0/0, ::/0',
          dns: '1.1.1.1',
          persistent_keepalive: 0,
          endpoint: '2.2.2.2:51820',
          last_online: nil,
          trafik: nil,
          data: {}
        },
        {
          id: 2,
          server_public_key: '4',
          address: '10.8.0.3/24',
          private_key: '1',
          public_key: '2',
          preshared_key: '3',
          enable: false,
          allowed_ips: '0.0.0.0/0, ::/0',
          dns: '1.1.1.1',
          persistent_keepalive: 0,
          endpoint: '2.2.2.2:51820',
          last_online: nil,
          trafik: nil,
          data: {}
        }
      ]
    end

    it 'serializes multiple configs' do
      expect(serialize).to eq(expected_result.to_json)
    end
  end
end
