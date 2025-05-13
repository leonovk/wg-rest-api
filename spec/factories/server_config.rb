# frozen_string_literal: true

module Factories
  class ServerConfig < BaseFactory
    def initialize # rubocop:disable Lint/MissingSuper
      @table_name = :server_configs
    end

    def params
      {
        private_key: '6Mlqg+1Umojm7a4VvgIi+YMp4oPrWNnZ5HLRFu4my2w=',
        public_key: 'uygGKpQt7gOwrP+bqkiXytafHiM+XqFGc0jtZVJ5bnw=',
        address: '10.8.0.1',
        address_ipv6: 'fdcc:ad94:bacf:61a4::cafe:1'
      }
    end
  end
end
