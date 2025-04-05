# frozen_string_literal: true

module Server
  # server serializer
  class Serializer
    def self.serialize(config)
      new(config).serialize
    end

    def serialize # rubocop:disable Metrics/MethodLength
      {
        server: config['server'],
        clients_count: config['configs'].except('last_id', 'last_address').size,
        available_clients_count: available_addresses_count,
        dns: Clients::Serializer::DNS,
        host: Clients::Serializer::WG_HOST,
        allowed_ips: Clients::Serializer::WG_ALLOWED_IPS,
        persistent_keepalive: Clients::Serializer::WG_PERSISTENT_KEEPALIVE,
        port: Clients::Serializer::WG_PORT,
        connecting_client_limit: Clients::Serializer::CONNECTING_CLIENT_LIMIT
      }.to_json
    end

    def initialize(config)
      @config = config
    end

    private

    attr_reader :config

    def available_addresses_count
      (2**(32 - WireGuard::ClientConfigBuilder::CONNECTING_CLIENT_LIMIT)) - 2
    end
  end
end
