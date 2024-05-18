# frozen_string_literal: true

RSpec.describe ClientsController do
  subject(:controller) { described_class.new }

  let(:wg_conf_path) { "#{Settings.wg_path}/wg0.json" }

  before do
    allow(WireGuard::ConfigUpdater).to receive(:update)
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
            address: '10.8.0.1'
          },
          configs: {
            last_id: 0,
            last_address: '10.8.0.1'
          }
        }
      end

      it 'creates a configuration file and returns an empty array' do # rubocop:disable RSpec/MultipleExpectations
        result = controller.index

        expect(result).to eq([].to_json)

        config = File.read(wg_conf_path)

        expect(config).to eq(JSON.pretty_generate(expected_result))
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
            address: '10.8.0.2/24',
            private_key: 'MJn6fwoyqG8S6wsrJzWrUow4leZuEM9O8s+G+kcXElU=',
            public_key: 'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=',
            preshared_key: '3UzAMA6mLIGjHOImShNb5tWlkwxsha8LZZP7dm49meQ=',
            allowed_ips: '0.0.0.0/0, ::/0',
            dns: '1.1.1.1',
            persistent_keepalive: 0,
            endpoint: '2.2.2.2:51820',
            data: {
              lol: 'kek'
            }
          },
          {
            id: 2,
            server_public_key: 'uygGKpQt7gOwrP+bqkiXytafHiM+XqFGc0jtZVJ5bnw=',
            address: '10.8.0.3/24',
            private_key: 'aN7ye98FKrmydwfA6tHgHE1PbiidWzUJ9cltnies8F4=',
            public_key: 'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=',
            preshared_key: 'dVW/5kF8wnsx0zAwR4uPIa06btACxpQ/rHBL1B3qPnk=',
            allowed_ips: '0.0.0.0/0, ::/0',
            dns: '1.1.1.1',
            persistent_keepalive: 0,
            endpoint: '2.2.2.2:51820',
            data: {
              cheburek: 'hah'
            }
          },
          {
            id: 3,
            server_public_key: 'uygGKpQt7gOwrP+bqkiXytafHiM+XqFGc0jtZVJ5bnw=',
            address: '10.8.0.4/24',
            private_key: 'eF3Owsqd5MGAIXjmALGBi8ea8mkFUmAiyh80U3hVXn8=',
            public_key: 'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=',
            preshared_key: 'IyVg7fktkSBxJ0uK82j6nlI7Vmo0E53eBmYZ723/45E=',
            allowed_ips: '0.0.0.0/0, ::/0',
            dns: '1.1.1.1',
            persistent_keepalive: 0,
            endpoint: '2.2.2.2:51820',
            data: {
              key: 'value'
            }
          }
        ]
      end

      it 'returns a serialized array with all clients' do
        expect(controller.index).to eq(expected_result.to_json)
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
          address: '10.8.0.3/24',
          private_key: 'aN7ye98FKrmydwfA6tHgHE1PbiidWzUJ9cltnies8F4=',
          public_key: 'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=',
          preshared_key: 'dVW/5kF8wnsx0zAwR4uPIa06btACxpQ/rHBL1B3qPnk=',
          allowed_ips: '0.0.0.0/0, ::/0',
          dns: '1.1.1.1',
          persistent_keepalive: 0,
          endpoint: '2.2.2.2:51820',
          data: {
            cheburek: 'hah'
          }
        }
      end

      it 'returns the correct serialized config' do
        result = controller.show('2')

        expect(result).to eq(expected_result.to_json)
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
        address: '10.8.0.2/24',
        private_key: 'wg_genkey',
        public_key: 'wg_pubkey',
        preshared_key: 'wg_genpsk',
        allowed_ips: '0.0.0.0/0, ::/0',
        dns: '1.1.1.1',
        persistent_keepalive: 0,
        endpoint: '2.2.2.2:51820',
        data: nil
      }
    end

    let(:expected_config_file) do
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
            data: nil
          }
        }
      }
    end

    it 'return new config' do
      expect(controller.create(nil)).to eq(expected_result.to_json)
    end

    it 'creates a new config file in the server configuration file' do
      controller.create(nil)

      json_config = File.read(wg_conf_path)

      expect(json_config).to eq(JSON.pretty_generate(expected_config_file))
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
            address: '10.8.0.1'
          },
          configs: {
            last_id: 3,
            last_address: '10.8.0.4',
            '1' => {
              id: 1,
              address: '10.8.0.2',
              private_key: 'MJn6fwoyqG8S6wsrJzWrUow4leZuEM9O8s+G+kcXElU=',
              public_key: 'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=',
              preshared_key: '3UzAMA6mLIGjHOImShNb5tWlkwxsha8LZZP7dm49meQ=',
              data: {
                lol: 'kek'
              }
            },
            '3' => {
              id: 3,
              address: '10.8.0.4',
              private_key: 'eF3Owsqd5MGAIXjmALGBi8ea8mkFUmAiyh80U3hVXn8=',
              public_key: 'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=',
              preshared_key: 'IyVg7fktkSBxJ0uK82j6nlI7Vmo0E53eBmYZ723/45E=',
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

        expect(json_config).to eq(JSON.pretty_generate(expected_result))
      end
    end

    context 'when the required config is missing' do
      it 'raises an error stating that this config is not on the server' do
        expect { controller.destroy('17') }.to raise_error(Errors::ConfigNotFoundError)
      end
    end
  end
end
