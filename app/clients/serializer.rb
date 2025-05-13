# frozen_string_literal: true

module Clients
  # serializer for config files
  class Serializer
    DNS = Settings.wg_default_dns
    WG_ALLOWED_IPS = Settings.wg_allowed_ips
    WG_PERSISTENT_KEEPALIVE = Settings.wg_persistent_keepalive
    WG_HOST = Settings.wg_host
    WG_PORT = Settings.wg_port
    CONNECTING_CLIENT_LIMIT = Settings.connecting_client_limit
    CONNECTING_CLIENT_LIMIT_6 = Settings.connecting_client_limit_6

    def self.serialize(client_config, server_public_key)
      new(client_config, server_public_key).client.to_json
    end

    def self.each_serialize(client_config, server_public_key)
      new(client_config, server_public_key).clients.to_json
    end

    def initialize(client_config, server_public_key)
      @client_config = client_config
      @server_public_key = server_public_key
      @server_stat = WireGuard::ServerStat.new
    end

    def clients
      client_config.map do |config|
        client(config)
      end
    end

    def client(config = client_config) # rubocop:disable Metrics/MethodLength
      {
        id: config[:id],
        server_public_key:,
        address: "#{config[:address]}/#{CONNECTING_CLIENT_LIMIT}",
        address_ipv6: "#{config[:address_ipv6]}/#{CONNECTING_CLIENT_LIMIT_6}",
        private_key: config[:private_key],
        public_key: config[:public_key],
        preshared_key: config[:preshared_key],
        enable: config[:enable],
        allowed_ips: WG_ALLOWED_IPS,
        dns: DNS,
        persistent_keepalive: WG_PERSISTENT_KEEPALIVE,
        endpoint: "#{WG_HOST}:#{WG_PORT}",
        last_online: find_stat_data(config[:public_key])[:last_online],
        traffic: traffic(config[:public_key]),
        data: JSON.parse(config[:data])
      }
    end

    private

    attr_reader :client_config, :server_public_key, :server_stat

    def find_stat_data(public_key)
      server_stat.show(public_key)
    end

    def traffic(public_key)
      data = find_stat_data(public_key)

      {
        received: data[:received],
        sent: data[:sent]
      }
    end
  end
end
