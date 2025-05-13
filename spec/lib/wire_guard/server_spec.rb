# frozen_string_literal: true

RSpec.describe WireGuard::Server do
  before do
    allow(WireGuard::ServerConfigUpdater).to receive(:update)
    allow(WireGuard::KeyGenerator).to receive_messages(wg_genkey: 'wg_genkey', wg_pubkey: 'wg_pubkey',
                                                       wg_genpsk: 'wg_genpsk')
  end

  after do
    clear_all_tables
  end

  describe '#initialize' do
    subject(:server) { described_class.new }

    context 'when the config file already exists' do
      before do
        Factories::ServerConfig.build
      end

      it 'correctly initializes the servers private key' do
        expect(server.server_private_key).to eq('6Mlqg+1Umojm7a4VvgIi+YMp4oPrWNnZ5HLRFu4my2w=')
      end

      it 'correctly initializes the servers public key' do
        expect(server.server_public_key).to eq('uygGKpQt7gOwrP+bqkiXytafHiM+XqFGc0jtZVJ5bnw=')
      end
    end

    context 'when there is no config file' do
      let(:expected_result) do
        {
          private_key: 'wg_genkey',
          public_key: 'wg_pubkey',
          address: '10.8.0.1',
          address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:1'
        }
      end

      it 'correctly initializes the servers private key' do
        expect(server.server_private_key).to eq('wg_genkey')
      end

      it 'correctly initializes the servers public key' do
        expect(server.server_public_key).to eq('wg_pubkey')
      end

      it 'initializes the configuration file' do
        server

        config_server = WireGuard::Repository.new.last_server_config

        expect(config_server.except(:id)).to eq(expected_result)
      end
    end
  end

  describe '#new_config' do
    subject(:new_config) { described_class.new.new_config(params) }

    let(:params) do
      {
        lol: 'kek'
      }
    end

    let(:expected_result) do
      {
        address: '10.8.0.2',
        address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:2',
        private_key: 'wg_genkey',
        public_key: 'wg_pubkey',
        preshared_key: 'wg_genpsk',
        enable: true,
        data: {
          lol: 'kek'
        }.to_json
      }
    end

    it 'creates a new config for the client' do
      new_config

      config = WireGuard::Repository.new.all_client_configs.last

      expect(config.except(:id)).to eq(expected_result)
    end

    it 'returns new client config' do
      expect(new_config.except(:id)).to eq(expected_result)
    end

    it 'calls the configuration file update service WireGuard' do
      new_config

      expect(WireGuard::ServerConfigUpdater).to have_received(:update)
    end
  end

  describe '#all_configs' do
    subject(:all_configs) { described_class.new.all_configs }

    context 'when there are no configs on the server' do
      it 'returns an empty hash' do
        expect(all_configs).to eq([])
      end
    end

    context 'when the server has configs' do
      before do
        Factories::ClientConfig.build({
                                        address: '10.8.0.1',
                                        address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:1'
                                      })

        Factories::ClientConfig.build({
                                        address: '10.8.0.2',
                                        address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:2'
                                      })

        Factories::ClientConfig.build({
                                        address: '10.8.0.3',
                                        address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:3'
                                      })
      end

      it 'returns a hash with configs for clients' do
        expect(all_configs.size).to eq(3)
      end
    end
  end

  describe '#config' do
    subject(:config) { described_class.new.config(id) }

    context 'when the requested config is not on the server' do
      let(:config) { Factories::ClientConfig.build }
      let(:id) { config[:id] + 1 }

      it 'raises an error stating that this config is not on the server' do
        expect { config }.to raise_error(Errors::ConfigNotFoundError)
      end
    end

    context 'when the requested config is on the server' do
      let(:config) { Factories::ClientConfig.build }
      let(:id) { config[:id] }

      it 'returns client config' do
        expect(config).to include(:id, :address, :address_ipv6)
      end
    end
  end

  describe '#delete_config' do
    subject(:delete_config) { described_class.new.delete_config(id) }

    context 'when the config to be deleted is on the server' do
      let(:config) { Factories::ClientConfig.build }
      let(:id) { config[:id] }

      it 'deletes the config from the server' do
        delete_config

        config = WireGuard::Repository.new.find_client_config_by_id(id)

        expect(config).to be_nil
      end

      it 'calls the configuration file update service WireGuard' do
        delete_config

        expect(WireGuard::ServerConfigUpdater).to have_received(:update)
      end
    end

    context 'when the config to be deleted is not on the server' do
      let(:id) { '4' }

      it 'raises an error stating that this config is not on the server' do
        expect { delete_config }.to raise_error(Errors::ConfigNotFoundError)
      end
    end
  end

  describe '#update_config' do
    subject(:update_config) { described_class.new.update_config(id, config_params) }

    context 'when the config to be updated is on the server' do
      let(:config) { Factories::ClientConfig.build }
      let(:id) { config[:id] }
      let(:config_params) do
        {
          'address' => '10.8.0.200',
          'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:17',
          'private_key' => 'a',
          'public_key' => 'b',
          'enable' => false,
          'data' => {}
        }
      end
      let(:expected_config) do
        {
          address: '10.8.0.200',
          address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:17',
          private_key: 'a',
          public_key: 'b',
          preshared_key: '3UzAMA6mLIGjHOImShNb5tWlkwxsha8LZZP7dm49meQ=',
          enable: false,
          data: {}
        }
      end

      it 'updates the config from the server' do
        update_config

        config = WireGuard::Repository.new.find_client_config_by_id(id)

        expect(config.except(:id)).to eq(expected_config)
      end

      it 'returns updated config' do
        expect(update_config.except(:id)).to eq(expected_config)
      end

      it 'calls the configuration file update service WireGuard' do
        update_config

        expect(WireGuard::ServerConfigUpdater).to have_received(:update)
      end
    end

    context 'when the config to be updated is not on the server' do
      let(:id) { '4' }
      let(:config_params) do
        {
          'address' => '10.8.0.200',
          'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:17',
          'private_key' => 'a',
          'public_key' => 'b',
          'enable' => false,
          'data' => {}
        }
      end

      it 'raises an error stating that this config is not on the server' do
        expect { update_config }.to raise_error(Errors::ConfigNotFoundError)
      end
    end

    context 'when the date contains data and the updated data does not match' do
      let(:id) { '1' }
      let(:config_params) do
        {
          'address' => '10.8.0.200',
          'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:17',
          'private_key' => 'a',
          'public_key' => 'b',
          'enable' => false,
          'data' => {
            'hah' => 'cheburek'
          }
        }
      end
      let(:expected_config) do
        {
          'id' => 1,
          'address' => '10.8.0.200',
          'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:17',
          'private_key' => 'a',
          'public_key' => 'b',
          'preshared_key' => '3UzAMA6mLIGjHOImShNb5tWlkwxsha8LZZP7dm49meQ=',
          'enable' => false,
          'data' => {
            'lol' => 'kek',
            'hah' => 'cheburek'
          }
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
              'preshared_key' => '3UzAMA6mLIGjHOImShNb5tWlkwxsha8LZZP7dm49meQ=',
              'enable' => false,
              'data' => {
                'lol' => 'kek',
                'hah' => 'cheburek'
              }
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

      it 'updates the config from the server' do
        update_config

        config = File.read(wg_conf_path)

        expect(config).to eq(JSON.pretty_generate(expected_result))
      end

      it 'returns updated config' do
        expect(update_config).to eq(expected_config)
      end

      it 'calls the configuration file update service WireGuard' do
        update_config

        expect(WireGuard::ServerConfigUpdater).to have_received(:update)
      end
    end

    context 'when the date is not transmitted at all' do
      let(:id) { '1' }
      let(:config_params) do
        {
          'address' => '10.8.0.200',
          'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:17',
          'private_key' => 'a',
          'public_key' => 'b',
          'enable' => false
        }
      end
      let(:expected_config) do
        {
          'id' => 1,
          'address' => '10.8.0.200',
          'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:17',
          'private_key' => 'a',
          'public_key' => 'b',
          'preshared_key' => '3UzAMA6mLIGjHOImShNb5tWlkwxsha8LZZP7dm49meQ=',
          'enable' => false,
          'data' => {
            'lol' => 'kek'
          }
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
              'preshared_key' => '3UzAMA6mLIGjHOImShNb5tWlkwxsha8LZZP7dm49meQ=',
              'enable' => false,
              'data' => {
                'lol' => 'kek'
              }
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

      it 'updates the config from the server' do
        update_config

        config = File.read(wg_conf_path)

        expect(config).to eq(JSON.pretty_generate(expected_result))
      end

      it 'returns updated config' do
        expect(update_config).to eq(expected_config)
      end

      it 'calls the configuration file update service WireGuard' do
        update_config

        expect(WireGuard::ServerConfigUpdater).to have_received(:update)
      end
    end

    context 'when the specified address is already in use by another client' do
      let(:id) { '1' }
      let(:config_params) do
        {
          'address' => '10.8.0.3',
          'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:3',
          'private_key' => 'a',
          'public_key' => 'b',
          'enable' => false
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
              'address_ipv6' => 'fdcc:ad94:bacf:61a4::cafe:2',
              'private_key' => 'a',
              'public_key' => 'b',
              'preshared_key' => '3UzAMA6mLIGjHOImShNb5tWlkwxsha8LZZP7dm49meQ=',
              'enable' => false,
              'data' => {
                'lol' => 'kek'
              }
            },
            '2' => {
              'id' => 2,
              'address' => '10.8.0.3',
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

      it 'causes an error that the address is already taken' do
        expect { update_config }.to raise_error(Errors::AddressAlreadyTakenError)
      end
    end
  end
end
