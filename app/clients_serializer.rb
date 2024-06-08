# frozen_string_literal: true

# serializer for config files
class ClientsSerializer
  DNS = Settings.wg_default_dns
  WG_ALLOWED_IPS = Settings.wg_allowed_ips
  WG_PERSISTENT_KEEPALIVE = Settings.wg_persistent_keepalive
  WG_HOST = Settings.wg_host
  WG_PORT = Settings.wg_port
  WG_STAT_PATH = "#{Settings.wg_path}/wg0_stat.json".freeze

  def self.serialize(client_config, server_public_key)
    new(client_config, server_public_key).client.to_json
  end

  def self.each_serialize(client_config, server_public_key)
    new(client_config, server_public_key).clients.to_json
  end

  # NOTE: If an instance of a class is created through the each_serialize method,
  # then the client_config variable will contain a hash with configs of the type:
  # {
  #  '1' => {
  #    id: 1,
  #    address: '10.8.0.2',
  #    private_key: '1',
  #    public_key: '2',
  #    preshared_key: '3',
  #    data: {}
  #  },
  #  '2' => {
  #    id: 2,
  #    address: '10.8.0.3',
  #    private_key: '1',
  #    public_key: '2',
  #    preshared_key: '3',
  #    data: {}
  #  }
  # }
  def initialize(client_config, server_public_key)
    @client_config = stringify_keys(client_config)
    @server_public_key = server_public_key
    @server_stat = WireGuard::ServerStat.new
  end

  def clients
    client_config.map do |_config_id, config|
      client(config)
    end
  end

  def client(config = client_config) # rubocop:disable Metrics/MethodLength
    {
      id: config['id'],
      server_public_key:,
      address: "#{config['address']}/24",
      private_key: config['private_key'],
      public_key: config['public_key'],
      preshared_key: config['preshared_key'],
      enable: config['enable'],
      allowed_ips: WG_ALLOWED_IPS,
      dns: DNS,
      persistent_keepalive: WG_PERSISTENT_KEEPALIVE,
      endpoint: "#{WG_HOST}:#{WG_PORT}",
      last_online: find_stat_data(config['public_key'])['last_online'],
      trafik: find_stat_data(config['public_key'])['trafik'],
      data: config['data']
    }
  end

  private

  attr_reader :client_config, :server_public_key, :server_stat

  def find_stat_data(public_key)
    stringify_keys(server_stat.wg_stat[public_key]) || stat_from_data(public_key) || {}
  end

  def stat_from_data(public_key)
    return unless File.exist?(WG_STAT_PATH)

    json_stat = JSON.parse(File.read(WG_STAT_PATH))

    json_stat[public_key]
  end

  def stringify_keys(data)
    data.is_a?(Hash) ? data.to_h { |k, v| [k.to_s, stringify_keys(v)] } : data
  end
end
