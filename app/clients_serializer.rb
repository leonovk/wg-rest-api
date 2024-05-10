# frozen_string_literal: true

# serializer for config files
class ClientsSerializer
  DNS = Settings.wg_default_dns
  WG_ALLOWED_IPS = Settings.wg_allowed_ips
  WG_PERSISTENT_KEEPALIVE = Settings.wg_persistent_keepalive
  WG_HOST = Settings.wg_host
  WG_PORT = Settings.wg_port

  def self.serialize(client_config, server_public_key)
    new(client_config, server_public_key).client.to_json
  end

  def initialize(client_config, server_public_key)
    @client_config = stringify_keys(client_config)
    @server_public_key = server_public_key
  end

  def client # rubocop:disable Metrics/MethodLength
    {
      id: client_config['id'],
      server_public_key:,
      address: "#{client_config['address']}/24",
      private_key: client_config['private_key'],
      preshared_key: client_config['preshared_key'],
      allowed_ips: WG_ALLOWED_IPS,
      dns: DNS,
      persistent_keepalive: WG_PERSISTENT_KEEPALIVE,
      endpoint: "#{WG_HOST}:#{WG_PORT}",
      data: client_config['data']
    }
  end

  private

  attr_reader :client_config, :server_public_key

  def stringify_keys(data)
    data.is_a?(Hash) ? data.to_h { |k, v| [k.to_s, stringify_keys(v)] } : data
  end
end
