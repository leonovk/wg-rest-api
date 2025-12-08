# frozen_string_literal: true

RSpec.describe Api::Clients::Controller do
  subject(:controller) { described_class.new }

  let(:wg_conf_path) { "#{Settings.wg_path}/wg0.json" }

  before do
    allow(WireGuard::ServerConfigUpdater).to receive(:update)
    allow(WireGuard::StatGenerator).to receive_messages(show: '')
    allow(WireGuard::KeyGenerator).to receive_messages(wg_genkey: 'wg_genkey', wg_pubkey: 'wg_pubkey',
                                                       wg_genpsk: 'wg_genpsk')
  end

  after do
    FileUtils.rm_rf(wg_conf_path)
  end

  describe '#index' do
    context 'when there is no configuration file' do
      let(:expected_result) do
        {
          server: {
            private_key: 'wg_genkey',
            public_key: 'wg_pubkey',
            address: '10.8.0.1',
            address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:1'
          },
          configs: {
            last_id: 0
          }
        }
      end

      it 'creates a configuration file and returns an empty array' do
        result = controller.index

        expect(result).to eq([].to_json)

        config = File.read(wg_conf_path)

        expect(JSON.parse(config)).to eq(stringify_keys(expected_result))
      end
    end

    context 'when there is already a configuration file without clients' do
      before do
        create_conf_file('spec/fixtures/empty_wg0.json')
      end

      it 'returns an empty array' do
        expect(controller.index).to eq([].to_json)
      end
    end

    context 'when there is already a configuration file with clients' do
      before do
        create_conf_file('spec/fixtures/wg0.json')
      end

      let(:expected_result) do
        [
          {
            id: 1,
            server_public_key: 'uygGKpQt7gOwrP+bqkiXytafHiM+XqFGc0jtZVJ5bnw=',
            address: '10.8.0.2/29',
            address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:2/120',
            private_key: 'MJn6fwoyqG8S6wsrJzWrUow4leZuEM9O8s+G+kcXElU=',
            public_key: 'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=',
            preshared_key: '3UzAMA6mLIGjHOImShNb5tWlkwxsha8LZZP7dm49meQ=',
            enable: true,
            allowed_ips: '0.0.0.0/0, ::/0',
            dns: '1.1.1.1',
            persistent_keepalive: 0,
            endpoint: '2.2.2.2:51820',
            last_ip: nil,
            last_online: nil,
            traffic: nil,
            data: {
              lol: 'kek'
            }
          },
          {
            id: 2,
            server_public_key: 'uygGKpQt7gOwrP+bqkiXytafHiM+XqFGc0jtZVJ5bnw=',
            address: '10.8.0.3/29',
            address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:3/120',
            private_key: 'aN7ye98FKrmydwfA6tHgHE1PbiidWzUJ9cltnies8F4=',
            public_key: 'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=',
            preshared_key: 'dVW/5kF8wnsx0zAwR4uPIa06btACxpQ/rHBL1B3qPnk=',
            enable: false,
            allowed_ips: '0.0.0.0/0, ::/0',
            dns: '1.1.1.1',
            persistent_keepalive: 0,
            endpoint: '2.2.2.2:51820',
            last_ip: nil,
            last_online: nil,
            traffic: nil,
            data: {
              cheburek: 'hah'
            }
          },
          {
            id: 3,
            server_public_key: 'uygGKpQt7gOwrP+bqkiXytafHiM+XqFGc0jtZVJ5bnw=',
            address: '10.8.0.4/29',
            address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:4/120',
            private_key: 'eF3Owsqd5MGAIXjmALGBi8ea8mkFUmAiyh80U3hVXn8=',
            public_key: 'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=',
            preshared_key: 'IyVg7fktkSBxJ0uK82j6nlI7Vmo0E53eBmYZ723/45E=',
            enable: true,
            allowed_ips: '0.0.0.0/0, ::/0',
            dns: '1.1.1.1',
            persistent_keepalive: 0,
            endpoint: '2.2.2.2:51820',
            last_ip: nil,
            last_online: nil,
            traffic: nil,
            data: {
              key: 'value'
            }
          }
        ]
      end

      it 'returns a serialized array with all clients' do
        # TODO: The `stringify_keys` method seems to work incorrectly on arrays.
        # Need to understand what the reason is and change it
        expect(JSON.parse(controller.index)).to eq(JSON.parse(expected_result.to_json))
      end
    end
  end

  describe '#show' do
    before do
      create_conf_file('spec/fixtures/wg0.json')
    end

    context 'when the necessary config is available' do
      let(:expected_result) do
        {
          id: 2,
          server_public_key: 'uygGKpQt7gOwrP+bqkiXytafHiM+XqFGc0jtZVJ5bnw=',
          address: '10.8.0.3/29',
          address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:3/120',
          private_key: 'aN7ye98FKrmydwfA6tHgHE1PbiidWzUJ9cltnies8F4=',
          public_key: 'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=',
          preshared_key: 'dVW/5kF8wnsx0zAwR4uPIa06btACxpQ/rHBL1B3qPnk=',
          enable: false,
          allowed_ips: '0.0.0.0/0, ::/0',
          dns: '1.1.1.1',
          persistent_keepalive: 0,
          endpoint: '2.2.2.2:51820',
          last_ip: nil,
          last_online: nil,
          traffic: nil,
          data: {
            cheburek: 'hah'
          }
        }
      end

      it 'returns the correct serialized config' do
        result = controller.show('2')

        expect(JSON.parse(result)).to eq(stringify_keys(expected_result))
      end
    end

    context 'when the required config is missing' do
      it 'raises an error stating that this config is not on the server' do
        expect { controller.show('17') }.to raise_error(Errors::ConfigNotFoundError)
      end
    end
  end

  describe '#create' do
    let(:expected_result) do
      {
        id: 1,
        server_public_key: 'wg_pubkey',
        address: '10.8.0.2/29',
        address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:2/120',
        private_key: 'wg_genkey',
        public_key: 'wg_pubkey',
        preshared_key: 'wg_genpsk',
        enable: true,
        allowed_ips: '0.0.0.0/0, ::/0',
        dns: '1.1.1.1',
        persistent_keepalive: 0,
        endpoint: '2.2.2.2:51820',
        last_ip: nil,
        last_online: nil,
        traffic: nil,
        data: nil
      }
    end

    let(:expected_config_file) do
      {
        server: {
          private_key: 'wg_genkey',
          public_key: 'wg_pubkey',
          address: '10.8.0.1',
          address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:1'
        },
        configs: {
          last_id: 1,
          '1' => {
            id: 1,
            address: '10.8.0.2',
            address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:2',
            private_key: 'wg_genkey',
            public_key: 'wg_pubkey',
            preshared_key: 'wg_genpsk',
            allowed_ips: '0.0.0.0/0, ::/0',
            enable: true,
            data: nil
          }
        }
      }
    end

    it 'return new config' do
      expect(JSON.parse(controller.create(nil))).to eq(stringify_keys(expected_result))
    end

    it 'creates a new config file in the server configuration file' do
      controller.create(nil)

      json_config = File.read(wg_conf_path)

      expect(JSON.parse(json_config)).to eq(stringify_keys(expected_config_file))
    end
  end

  describe '#destroy' do
    before do
      create_conf_file('spec/fixtures/wg0.json')
    end

    context 'when the necessary config is available' do
      let(:expected_result) do
        {
          server: {
            private_key: '6Mlqg+1Umojm7a4VvgIi+YMp4oPrWNnZ5HLRFu4my2w=',
            public_key: 'uygGKpQt7gOwrP+bqkiXytafHiM+XqFGc0jtZVJ5bnw=',
            address: '10.8.0.1',
            address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:1'
          },
          configs: {
            last_id: 3,
            '1' => {
              id: 1,
              address: '10.8.0.2',
              address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:2',
              private_key: 'MJn6fwoyqG8S6wsrJzWrUow4leZuEM9O8s+G+kcXElU=',
              public_key: 'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=',
              preshared_key: '3UzAMA6mLIGjHOImShNb5tWlkwxsha8LZZP7dm49meQ=',
              enable: true,
              data: {
                lol: 'kek'
              }
            },
            '3' => {
              id: 3,
              address: '10.8.0.4',
              address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:4',
              private_key: 'eF3Owsqd5MGAIXjmALGBi8ea8mkFUmAiyh80U3hVXn8=',
              public_key: 'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=',
              preshared_key: 'IyVg7fktkSBxJ0uK82j6nlI7Vmo0E53eBmYZ723/45E=',
              enable: true,
              data: {
                key: 'value'
              }
            }
          }
        }
      end

      it 'returns an empty hash as result' do
        result = controller.destroy('2')

        expect(result).to eq({}.to_json)
      end

      it 'removes the required config from the configuration file' do
        controller.destroy('2')

        json_config = File.read(wg_conf_path)

        expect(JSON.parse(json_config)).to eq(stringify_keys(expected_result))
      end
    end

    context 'when the required config is missing' do
      it 'raises an error stating that this config is not on the server' do
        expect { controller.destroy('17') }.to raise_error(Errors::ConfigNotFoundError)
      end
    end
  end

  describe '#update' do
    before do
      create_conf_file('spec/fixtures/wg0.json')
    end

    context 'when the necessary config is available' do
      context 'when the parameters are valid' do
        let(:params) do
          {
            'address' => '10.8.0.200',
            'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:17',
            'private_key' => 'a',
            'public_key' => 'b',
            'preshared_key' => 'c',
            'enable' => false,
            'data' => {}
          }
        end
        let(:expected_result) do
          {
            'server' => {
              'private_key' => '6Mlqg+1Umojm7a4VvgIi+YMp4oPrWNnZ5HLRFu4my2w=',
              'public_key' => 'uygGKpQt7gOwrP+bqkiXytafHiM+XqFGc0jtZVJ5bnw=',
              'address' => '10.8.0.1',
              'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:1'
            },
            'configs' => {
              'last_id' => 3,
              '1' => {
                'id' => 1,
                'address' => '10.8.0.200',
                'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:17',
                'private_key' => 'a',
                'public_key' => 'b',
                'preshared_key' => 'c',
                'enable' => false,
                'data' => {}
              },
              '2' => {
                'id' => 2,
                'address' => '10.8.0.3',
                'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:3',
                'private_key' => 'aN7ye98FKrmydwfA6tHgHE1PbiidWzUJ9cltnies8F4=',
                'public_key' => 'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=',
                'preshared_key' => 'dVW/5kF8wnsx0zAwR4uPIa06btACxpQ/rHBL1B3qPnk=',
                'enable' => false,
                'data' => {
                  'cheburek' => 'hah'
                }
              },
              '3' => {
                'id' => 3,
                'address' => '10.8.0.4',
                'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:4',
                'private_key' => 'eF3Owsqd5MGAIXjmALGBi8ea8mkFUmAiyh80U3hVXn8=',
                'public_key' => 'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=',
                'preshared_key' => 'IyVg7fktkSBxJ0uK82j6nlI7Vmo0E53eBmYZ723/45E=',
                'enable' => true,
                'data' => {
                  'key' => 'value'
                }
              }
            }
          }
        end
        let(:expected_updated_config) do
          {
            id: 1,
            server_public_key: 'uygGKpQt7gOwrP+bqkiXytafHiM+XqFGc0jtZVJ5bnw=',
            address: '10.8.0.200/29',
            address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:17/120',
            private_key: 'a',
            public_key: 'b',
            preshared_key: 'c',
            enable: false,
            allowed_ips: '0.0.0.0/0, ::/0',
            dns: '1.1.1.1',
            persistent_keepalive: 0,
            endpoint: '2.2.2.2:51820',
            last_ip: nil,
            last_online: nil,
            traffic: nil,
            data: {}
          }
        end

        it 'updates the config from the server' do
          controller.update('1', params)

          config = File.read(wg_conf_path)

          expect(JSON.parse(config)).to eq(stringify_keys(expected_result))
        end

        it 'returns the updated serialized config' do
          expect(JSON.parse(controller.update('1', params))).to eq(stringify_keys(expected_updated_config))
        end
      end

      context 'when the parameters are not valid' do
        let(:params) do
          {
            'address' => '10.8.0.200',
            'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:17',
            'private_key' => 'a',
            'public_key' => 1,
            'preshared_key' => 'c',
            'enable' => 'false',
            'data' => {}
          }
        end

        it 'raises a validation error' do
          expect { controller.update('1', params) }.to raise_error(JSON::Schema::ValidationError)
        end
      end
    end

    context 'when the required config is missing' do
      it 'raises an error stating that this config is not on the server' do
        expect { controller.update('17', {}) }.to raise_error(Errors::ConfigNotFoundError)
      end
    end
  end
end
