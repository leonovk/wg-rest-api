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
      it 'correctly initializes the servers private key' do
        expect(server.server_private_key).to eq('wg_genkey')
      end

      it 'correctly initializes the servers public key' do
        expect(server.server_public_key).to eq('wg_pubkey')
      end
    end
  end
end
