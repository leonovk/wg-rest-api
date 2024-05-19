# frozen_string_literal: true

RSpec.describe WireGuard::ConfigBuilder do
  subject(:build) { described_class.new(configs, params).config }

  before do
    allow(WireGuard::KeyGenerator).to receive_messages(wg_genkey: 'wg_genkey', wg_pubkey: 'wg_pubkey',
                                                       wg_genpsk: 'wg_genpsk')
  end

  let(:params) do
    {
      lol: 'kek'
    }
  end

  let(:configs) do
    {
      'last_id' => 23,
      'last_address' => '10.8.0.255'
    }
  end

  let(:expected_result) do
    {
      id: 24,
      address: '10.8.1.0',
      private_key: 'wg_genkey',
      public_key: 'wg_pubkey',
      preshared_key: 'wg_genpsk',
      enable: true,
      data: {
        lol: 'kek'
      }
    }
  end

  it 'creates the correct config' do
    expect(build).to eq(expected_result)
  end
end
