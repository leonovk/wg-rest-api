# frozen_string_literal: true

module WireGuard
  # The class generates a config file for the client
  class ClientConfigBuilder
    WG_DEFAULT_ADDRESS = IPAddr.new(Settings.wg_default_address.gsub('x', '1'))
    CONNECTING_CLIENT_LIMIT = Settings.connecting_client_limit.to_i

    attr_reader :config

    def initialize(configs, params)
      @wg_genkey = KeyGenerator.wg_genkey
      @configs = configs
      check_availability_of_space!
      @config = build_config(params)
    end

    private

    attr_reader :wg_genkey, :configs

    def build_config(params)
      {
        id: configs['last_id'] + 1,
        address: new_last_ip,
        private_key: wg_genkey,
        public_key: KeyGenerator.wg_pubkey(wg_genkey),
        preshared_key: KeyGenerator.wg_genpsk,
        enable: true,
        data: params
      }
    end

    def new_last_ip
      IPAddr.new(find_current_last_ip.to_i + 1, Socket::AF_INET).to_s
    end

    def check_availability_of_space!
      return unless all_ip_addresses.size >= available_addresses_count

      raise Errors::ConnectionLimitExceededError
    end

    def available_addresses_count
      (2**(32 - CONNECTING_CLIENT_LIMIT)) - 2
    end

    def all_ip_addresses
      @all_ip_addresses ||= begin
        configs.except('last_id').map do |_id, config|
          IPAddr.new(config['address'])
        end << WG_DEFAULT_ADDRESS
      end.sort
    end

    def find_current_last_ip
      all_ip_addresses.each_with_index do |ip, index|
        next_ip = all_ip_addresses[index + 1]

        return ip if next_ip.nil? || (next_ip.to_i - ip.to_i) > 1
      end
    end
  end
end
