# frozen_string_literal: true

RSpec.describe WireGuard::Server do
  before do
    allow(WireGuard::ConfigUpdater).to receive(:update)
    allow(WireGuard::KeyGenerator).to receive_messages(wg_genkey: 'wg_genkey', wg_pubkey: 'wg_pubkey',
                                                       wg_genpsk: 'wg_genpsk')
  end

  after do
    FileUtils.rm_rf(wg_conf_path)
  end

  let(:wg_conf_path) { "#{Settings.wg_path}/wg0.json" }

  describe '#initialize' do
    subject(:server) { described_class.new }

    context 'when the config file already exists' do
      before do
        create_conf_file('spec/fixtures/wg0.json')
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
          server: {
            private_key: 'wg_genkey',
            public_key: 'wg_pubkey',
            address: '10.8.0.1'
          },
          configs: {
            last_id: 0,
            last_address: '10.8.0.1'
          }
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

        config = File.read(wg_conf_path)

        expect(config).to eq(JSON.pretty_generate(expected_result))
      end
    end
  end

  describe '#new_config' do
    subject(:new_config) { described_class.new.new_config(params) }

    before do
      create_conf_file('spec/fixtures/empty_wg0.json')
    end

    let(:params) do
      {
        lol: 'kek'
      }
    end

    let(:expected_result) do
      {
        id: 1,
        address: '10.8.0.2',
        private_key: 'wg_genkey',
        public_key: 'wg_pubkey',
        preshared_key: 'wg_genpsk',
        data: {
          lol: 'kek'
        }
      }
    end

    let(:expected_conf_file) do
      {
        server: {
          private_key: 'wg_genkey',
          public_key: 'wg_pubkey',
          address: '10.8.0.1'
        },
        configs: {
          last_id: 1,
          last_address: '10.8.0.2',
          '1' => {
            id: 1,
            address: '10.8.0.2',
            private_key: 'wg_genkey',
            public_key: 'wg_pubkey',
            preshared_key: 'wg_genpsk',
            data: {
              lol: 'kek'
            }
          }
        }
      }
    end

    it 'creates a new config for the client' do
      new_config

      config = File.read(wg_conf_path)

      expect(config).to eq(JSON.pretty_generate(expected_conf_file))
    end

    it 'returns new client config' do
      expect(new_config).to eq(expected_result)
    end

    it 'calls the configuration file update service WireGuard' do
      new_config

      expect(WireGuard::ConfigUpdater).to have_received(:update)
    end
  end

  describe '#all_configs' do
    subject(:all_configs) { described_class.new.all_configs }

    context 'when there are no configs on the server' do
      before do
        create_conf_file('spec/fixtures/empty_wg0.json')
      end

      it 'returns an empty hash' do
        expect(all_configs).to eq({})
      end
    end

    context 'when the server has configs' do
      before do
        create_conf_file('spec/fixtures/wg0.json')
      end

      let(:expected_result) do
        {
          '1' => {
            'id' => 1,
            'address' => '10.8.0.2',
            'private_key' => 'MJn6fwoyqG8S6wsrJzWrUow4leZuEM9O8s+G+kcXElU=',
            'public_key' => 'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=',
            'preshared_key' => '3UzAMA6mLIGjHOImShNb5tWlkwxsha8LZZP7dm49meQ=',
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
            'data' => {
              'key' => 'value'
            }
          }
        }
      end

      it 'returns a hash with configs for clients' do
        expect(all_configs).to eq(expected_result)
      end
    end
  end

  describe '#config' do
    subject(:config) { described_class.new.config(id) }

    before do
      create_conf_file('spec/fixtures/wg0.json')
    end

    context 'when the requested config is not on the server' do
      let(:id) { '13' }

      it 'return nil' do
        expect(config).to be_nil
      end
    end

    context 'when the requested config is on the server' do
      let(:id) { '2' }

      let(:expected_result) do
        {
          'id' => 2,
          'address' => '10.8.0.3',
          'private_key' => 'aN7ye98FKrmydwfA6tHgHE1PbiidWzUJ9cltnies8F4=',
          'public_key' => 'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=',
          'preshared_key' => 'dVW/5kF8wnsx0zAwR4uPIa06btACxpQ/rHBL1B3qPnk=',
          'data' => {
            'cheburek' => 'hah'
          }
        }
      end

      it 'returns client config' do
        expect(config).to eq(expected_result)
      end
    end
  end

  describe '#delete_config' do
    subject(:delete_config) { described_class.new.delete_config(id) }

    before do
      create_conf_file('spec/fixtures/wg0.json')
    end

    context 'when the config to be deleted is on the server' do
      let(:id) { '1' }
      let(:expected_result) do
        {
          'server' => {
            'private_key' => '6Mlqg+1Umojm7a4VvgIi+YMp4oPrWNnZ5HLRFu4my2w=',
            'public_key' => 'uygGKpQt7gOwrP+bqkiXytafHiM+XqFGc0jtZVJ5bnw=',
            'address' => '10.8.0.1'
          },
          'configs' => {
            'last_id' => 3,
            'last_address' => '10.8.0.4',
            '2' => {
              'id' => 2,
              'address' => '10.8.0.3',
              'private_key' => 'aN7ye98FKrmydwfA6tHgHE1PbiidWzUJ9cltnies8F4=',
              'public_key' => 'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=',
              'preshared_key' => 'dVW/5kF8wnsx0zAwR4uPIa06btACxpQ/rHBL1B3qPnk=',
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
              'data' => {
                'key' => 'value'
              }
            }
          }
        }
      end

      it 'deletes the config from the server' do
        delete_config

        config = File.read(wg_conf_path)

        expect(config).to eq(JSON.pretty_generate(expected_result))
      end

      it 'return true' do
        expect(delete_config).to be(true)
      end

      it 'calls the configuration file update service WireGuard' do
        delete_config

        expect(WireGuard::ConfigUpdater).to have_received(:update)
      end
    end

    context 'when the config to be deleted is not on the server' do
      let(:id) { '4' }

      it 'return false' do
        expect(delete_config).to be(false)
      end

      it 'no calls the configuration file update service WireGuard' do
        delete_config

        expect(WireGuard::ConfigUpdater).not_to have_received(:update)
      end
    end
  end
end
