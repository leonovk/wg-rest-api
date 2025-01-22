# frozen_string_literal: true

RSpec.describe Application do
  include Rack::Test::Methods

  let(:app) { described_class }
  let(:wg_conf_path) { "#{Settings.wg_path}/wg0.json" }

  before do
    create_conf_file('spec/fixtures/wg0.json')
  end

  after do
    FileUtils.rm_rf(wg_conf_path)
  end

  describe 'GET /healthz' do
    before do
      get '/healthz'
    end

    let(:expected_body) do
      {
        status: 'ok',
        version: File.read('VERSION').gsub('v', '').gsub("\n", '')
      }
    end

    it 'returns the server state' do
      expect(last_response.body).to eq(expected_body.to_json)
    end
  end

  describe 'GET /api/clients' do
    before do
      allow(WireGuard::StatGenerator).to receive_messages(show: nil)
    end

    context 'when the request is authorized' do
      before do
        header('Authorization', 'Bearer 123-Ab')
        get '/api/clients'
      end

      it 'returns a successful response' do
        expect(last_response.successful?).to be(true)
      end
    end

    context 'when the request is authorized but an encrypted token is set' do
      before do
        allow(Settings).to receive(:auth_digest_token)
          .and_return('8c24220738721bb1a0ad0607527293c16d0d44f2a645980efc271a0a03006d4c')
        header('Authorization', 'Bearer 123-Ab')
        get '/api/clients'
      end

      it 'returns a successful response' do
        expect(last_response.successful?).to be(true)
      end
    end

    context 'when no authorization header was passed at all' do
      before do
        get '/api/clients'
      end

      it 'returns an unsuccessful response' do
        expect(last_response.successful?).to be(false)
        expect(last_response.status).to be(403)
      end
    end

    context 'when the request is not authorized' do
      before do
        header('Authorization', 'Bearer 123-ab')
        get '/api/clients'
      end

      it 'returns an unsuccessful response' do
        expect(last_response.successful?).to be(false)
        expect(last_response.status).to be(403)
      end
    end
  end

  describe 'GET /api/clients:id' do
    subject(:make_request) do
      get("/api/clients/#{id}", { 'CONTENT_TYPE' => 'application/json' })
    end

    before do
      allow(WireGuard::StatGenerator).to receive_messages(show: nil)

      header('Authorization', 'Bearer 123-Ab')
    end

    context 'when the requested client exists' do
      let(:id) { '1' }

      it 'returns a successful response' do
        make_request

        expect(last_response.successful?).to be(true)
      end
    end

    context 'when the requested client does not exist' do
      let(:id) { '23' }

      it 'returns a not_found response' do
        make_request

        expect(last_response.successful?).to be(false)
        expect(last_response.status).to eq(404)
      end
    end
  end

  describe 'PATCH /api/clients/:id' do
    subject(:make_request) do
      patch("/api/clients/#{id}",
            request_body.to_json,
            { 'CONTENT_TYPE' => 'application/json' })
    end

    before do
      allow(WireGuard::StatGenerator).to receive_messages(show: nil)
      allow(WireGuard::ServerConfigUpdater).to receive(:update)

      header('Authorization', 'Bearer 123-Ab')
    end

    let(:id) { '1' }

    shared_examples 'correctly updates the client config' do
      it 'returns a successful response' do
        make_request

        expect(last_response.successful?).to be(true)
      end

      it 'updates the config from the server' do
        make_request

        config = File.read(wg_conf_path)

        expect(config).to eq(JSON.pretty_generate(expected_result))
      end
    end

    context 'when a normal request for config update' do
      let(:request_body) do
        {
          address: '10.8.0.200',
          private_key: 'a',
          public_key: 'b',
          enable: false,
          data: {}
        }
      end

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
            '1' => {
              'id' => 1,
              'address' => '10.8.0.200',
              'private_key' => 'a',
              'public_key' => 'b',
              'preshared_key' => '3UzAMA6mLIGjHOImShNb5tWlkwxsha8LZZP7dm49meQ=',
              'enable' => false,
              'data' => {}
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

      include_examples 'correctly updates the client config'
    end

    context 'when an update arrives with a data parameter that updates the attribute' do
      let(:request_body) do
        {
          address: '10.8.0.200',
          private_key: 'a',
          public_key: 'b',
          enable: false,
          data: {
            lol: 'ne kekai'
          }
        }
      end

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
            '1' => {
              'id' => 1,
              'address' => '10.8.0.200',
              'private_key' => 'a',
              'public_key' => 'b',
              'preshared_key' => '3UzAMA6mLIGjHOImShNb5tWlkwxsha8LZZP7dm49meQ=',
              'enable' => false,
              'data' => {
                'lol' => 'ne kekai'
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

      include_examples 'correctly updates the client config'
    end

    context 'when there is no date parameter at all' do
      let(:request_body) do
        {
          address: '10.8.0.200',
          private_key: 'a',
          public_key: 'b',
          enable: false
        }
      end

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
            '1' => {
              'id' => 1,
              'address' => '10.8.0.200',
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

      include_examples 'correctly updates the client config'
    end

    context 'when the parameter with date expands it' do
      let(:request_body) do
        {
          address: '10.8.0.200',
          private_key: 'a',
          public_key: 'b',
          enable: false,
          data: {
            prikol: 'lol'
          }
        }
      end

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
            '1' => {
              'id' => 1,
              'address' => '10.8.0.200',
              'private_key' => 'a',
              'public_key' => 'b',
              'preshared_key' => '3UzAMA6mLIGjHOImShNb5tWlkwxsha8LZZP7dm49meQ=',
              'enable' => false,
              'data' => {
                'lol' => 'kek',
                'prikol' => 'lol'
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

      include_examples 'correctly updates the client config'
    end

    context 'when the config to be updated does not exist' do
      let(:id) { '23' }
      let(:request_body) do
        {
          address: '10.8.0.200',
          private_key: 'a',
          public_key: 'b',
          enable: false,
          data: {
            prikol: 'lol'
          }
        }
      end

      it 'returns a not_found response' do
        make_request

        expect(last_response.successful?).to be(false)
        expect(last_response.status).to eq(404)
      end
    end

    context 'when invalid data was passed to the input' do
      let(:id) { '1' }
      let(:request_body) do
        {
          addressss: '10.8.0.200'
        }
      end

      it 'returns error response' do
        make_request

        expect(last_response.successful?).to be(false)
        expect(last_response.status).to eq(400)
      end
    end
  end

  describe 'POST /api/clients' do
    subject(:make_request) do
      post('/api/clients',
           request_body.to_json,
           { 'CONTENT_TYPE' => 'application/json' })
    end

    before do
      allow(WireGuard::StatGenerator).to receive_messages(show: nil)
      allow(WireGuard::ServerConfigUpdater).to receive(:update)
      allow(WireGuard::KeyGenerator).to receive_messages(wg_genkey: 'wg_genkey', wg_pubkey: 'wg_pubkey',
                                                         wg_genpsk: 'wg_genpsk')

      header('Authorization', 'Bearer 123-Ab')
    end

    let(:request_body) do
      {
        hahaha: 'body'
      }
    end

    let(:expected_result) do
      {
        'server' => {
          'private_key' => '6Mlqg+1Umojm7a4VvgIi+YMp4oPrWNnZ5HLRFu4my2w=',
          'public_key' => 'uygGKpQt7gOwrP+bqkiXytafHiM+XqFGc0jtZVJ5bnw=',
          'address' => '10.8.0.1'
        },
        'configs' => {
          'last_id' => 4,
          'last_address' => '10.8.0.5',
          '1' => {
            'id' => 1,
            'address' => '10.8.0.2',
            'private_key' => 'MJn6fwoyqG8S6wsrJzWrUow4leZuEM9O8s+G+kcXElU=',
            'public_key' => 'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=',
            'preshared_key' => '3UzAMA6mLIGjHOImShNb5tWlkwxsha8LZZP7dm49meQ=',
            'enable' => true,
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
          },
          '4' => {
            'id' => 4,
            'address' => '10.8.0.5',
            'private_key' => 'wg_genkey',
            'public_key' => 'wg_pubkey',
            'preshared_key' => 'wg_genpsk',
            'enable' => true,
            'data' => {
              'hahaha' => 'body'
            }
          }
        }
      }
    end

    it 'returns a successful response' do
      make_request

      expect(last_response.successful?).to be(true)
    end

    it 'updates the config from the server' do
      make_request

      config = File.read(wg_conf_path)

      expect(config).to eq(JSON.pretty_generate(expected_result))
    end
  end
end
