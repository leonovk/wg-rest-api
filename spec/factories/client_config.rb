# frozen_string_literal: true

module Factories
  class ClientConfig < BaseFactory
    def initialize # rubocop:disable Lint/MissingSuper
      @table_name = :clients_configs
    end

    def params
      {
        private_key: SecureRandom.hex,
        public_key: SecureRandom.hex,
        preshared_key: SecureRandom.hex,
        address: '10.8.0.1',
        address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:1',
        data: {
          SecureRandom.hex => SecureRandom.rand.round(3)
        }.to_json
      }
    end
  end
end
