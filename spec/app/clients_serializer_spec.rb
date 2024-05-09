# frozen_string_literal: true

RSpec.describe ClientsSerializer do
  subject(:serialize) { described_class.serialize(config, key) }

  let(:config) do
    {
      id: 1,
      address: '10.8.0.2',
      private_key: '1',
      public_key: '2',
      preshared_key: '3',
      data: {}
    }
  end

  let(:key) { '4' }

  let(:excepted_result) do
    {
      id: 1,
      server_public_key: '4',
      address: '10.8.0.2/24',
      private_key: '1',
      preshared_key: '3',
      allowed_ips: '0.0.0.0/0, ::/0',
      dns: '1.1.1.1',
      persistent_keepalive: 0,
      endpoint: '2.2.2.2:51820',
      data: {}
    }.to_json
  end

  it do
    expect(serialize).to eq(excepted_result)
  end
end
