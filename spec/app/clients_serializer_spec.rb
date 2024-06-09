# frozen_string_literal: true

RSpec.describe ClientsSerializer do
  before do
    allow(WireGuard::StatGenerator).to receive_messages(show: wg_show_stub)
    create_conf_file('spec/fixtures/wg0_stat.json', wg_stat_path)
  end

  after do
    FileUtils.rm_rf(wg_stat_path)
  end

  let(:key) { '4' }
  let(:wg_stat_path) { "#{Settings.wg_path}/wg0_stat.json" }
  let(:wg_show_stub) { File.read('spec/fixtures/stat_with_empty.txt') }

  describe '#serialize' do
    subject(:serialize) { described_class.serialize(config, key) }

    let(:config) do
      {
        id: 1,
        address: '10.8.0.2',
        private_key: '1',
        public_key: 'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=',
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
        public_key: 'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=',
        preshared_key: '3',
        enable: true,
        allowed_ips: '0.0.0.0/0, ::/0',
        dns: '1.1.1.1',
        persistent_keepalive: 0,
        endpoint: '2.2.2.2:51820',
        last_online: '45 seconds ago',
        trafik: {
          received: '56.28 MiB',
          sent: '1.35 GiB'
        },
        data: {}
      }
    end

    it 'serializes one config' do
      expect(JSON.parse(serialize)).to eq(stringify_keys(expected_result))
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
          public_key: 'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=',
          preshared_key: '3',
          enable: true,
          data: {}
        },
        '2' => {
          id: 2,
          address: '10.8.0.3',
          private_key: '1',
          public_key: 'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=',
          preshared_key: '3',
          enable: false,
          data: {}
        },
        '3' => {
          id: 3,
          address: '10.8.0.4',
          private_key: '1',
          public_key: 'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=',
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
          public_key: 'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=',
          preshared_key: '3',
          enable: true,
          allowed_ips: '0.0.0.0/0, ::/0',
          dns: '1.1.1.1',
          persistent_keepalive: 0,
          endpoint: '2.2.2.2:51820',
          last_online: '45 seconds ago',
          trafik: {
            received: '56.28 MiB',
            sent: '1.35 GiB'
          },
          data: {}
        },
        {
          id: 2,
          server_public_key: '4',
          address: '10.8.0.3/24',
          private_key: '1',
          public_key: 'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=',
          preshared_key: '3',
          enable: false,
          allowed_ips: '0.0.0.0/0, ::/0',
          dns: '1.1.1.1',
          persistent_keepalive: 0,
          endpoint: '2.2.2.2:51820',
          last_online: '50 seconds ago',
          trafik: {
            received: '199.29 MiB',
            sent: '722.39 MiB'
          },
          data: {}
        },
        {
          id: 3,
          server_public_key: '4',
          address: '10.8.0.4/24',
          private_key: '1',
          public_key: 'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=',
          preshared_key: '3',
          enable: false,
          allowed_ips: '0.0.0.0/0, ::/0',
          dns: '1.1.1.1',
          persistent_keepalive: 0,
          endpoint: '2.2.2.2:51820',
          last_online: '13 seconds ago',
          trafik: {
            received: '0.12 GiB',
            sent: '6.42 GiB'
          },
          data: {}
        }
      ]
    end

    it 'serializes multiple configs' do
      expect(JSON.parse(serialize)).to eq(JSON.parse(expected_result.to_json))
    end
  end
end
