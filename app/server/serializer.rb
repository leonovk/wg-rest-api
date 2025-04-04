# frozen_string_literal: true

module Server
  # server serializer
  class Serializer
    def serialize(config)
      {
        server: config['server'],
        clients_count: config['configs'].except('last_id', 'last_address').size,
        available_clients_count: available_addresses_count
      }.to_json
    end

    def available_addresses_count
      (2**(32 - WireGuard::ClientConfigBuilder::CONNECTING_CLIENT_LIMIT)) - 2
    end
  end
end
