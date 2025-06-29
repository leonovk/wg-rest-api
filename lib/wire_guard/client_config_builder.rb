# frozen_string_literal: true

module WireGuard
  # The class generates a config file for the client
  class ClientConfigBuilder
    WG_DEFAULT_ADDRESS = {
      'address' => IPAddr.new(Settings.wg_default_address.gsub('x', '1')),
      'address_ipv6' => IPAddr.new(Settings.wg_default_address_6.gsub('x', '1'))
    }.freeze

    CONNECTING_CLIENT_LIMIT = Settings.connecting_client_limit.to_i
    CONNECTING_CLIENT_LIMIT_6 = Settings.connecting_client_limit_6.to_i
    WG_ALLOWED_IPS = Settings.wg_allowed_ips

    attr_reader :config

    def self.available_addresses_count
      [(2**(32 - CONNECTING_CLIENT_LIMIT)) - 2, 2**(128 - CONNECTING_CLIENT_LIMIT_6)].min
    end

    def initialize(configs, params)
      @wg_genkey = KeyGenerator.wg_genkey
      @configs = configs
      check_availability_of_space!
      @config = build_config(params)
    end

    private

    attr_reader :wg_genkey, :configs

    def build_config(params) # rubocop:disable Metrics/MethodLength
      {
        id: configs['last_id'] + 1,
        address: new_last_ip,
        address_ipv6: new_last_ipv6,
        private_key: wg_genkey,
        public_key: KeyGenerator.wg_pubkey(wg_genkey),
        preshared_key: KeyGenerator.wg_genpsk,
        allowed_ips: WG_ALLOWED_IPS,
        enable: true,
        data: params
      }
    end

    def new_last_ip
      IPAddr.new(find_current_last_ip.to_i + 1, Socket::AF_INET).to_s
    end

    def new_last_ipv6
      IPAddr.new(find_current_last_ip('address_ipv6').to_i + 1, Socket::AF_INET6).to_s
    end

    def check_availability_of_space!
      return unless all_ip_addresses.size >= self.class.available_addresses_count

      raise Errors::ConnectionLimitExceededError
    end

    def all_ip_addresses(ip_version_key = 'address')
      result = configs.except('last_id').filter_map do |_id, config|
        # NOTE: This is necessary in order to maintain backward compatibility
        # with those who still have the "last_address" field in the config.
        # In the next versions this needs to be removed along with the `filter_map`.
        next unless config.is_a?(Hash)

        IPAddr.new(config[ip_version_key])
      end << WG_DEFAULT_ADDRESS[ip_version_key]

      result.sort
    end

    def find_current_last_ip(ip_version_key = 'address')
      all_ip_addresses(ip_version_key).each_with_index do |ip, index|
        next_ip = all_ip_addresses(ip_version_key)[index + 1]

        return ip if next_ip.nil? || (next_ip.to_i - ip.to_i) > 1
      end
    end
  end
end
