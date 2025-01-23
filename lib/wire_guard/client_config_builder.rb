# frozen_string_literal: true

module WireGuard
  # The class generates a config file for the client
  class ClientConfigBuilder
    WG_DEFAULT_ADDRESS = IPAddr.new(Settings.wg_default_address.gsub('x', '1'))

    attr_reader :config

    def initialize(configs, params)
      @wg_genkey = KeyGenerator.wg_genkey
      @wg_pubkey = KeyGenerator.wg_pubkey(@wg_genkey)
      @wg_genpsk = KeyGenerator.wg_genpsk
      @configs = configs
      @config = build_config(params)
    end

    private

    attr_reader :wg_genkey, :wg_pubkey, :wg_genpsk, :configs

    def build_config(params)
      {
        id: configs['last_id'] + 1,
        address: new_last_ip,
        private_key: wg_genkey,
        public_key: wg_pubkey,
        preshared_key: wg_genpsk,
        enable: true,
        data: params
      }
    end

    def new_last_ip
      IPAddr.new(find_current_last_ip.to_i + 1, Socket::AF_INET).to_s
    end

    def find_current_last_ip
      ips = configs.except('last_id').map do |_id, config|
        IPAddr.new(config['address'])
      end << WG_DEFAULT_ADDRESS

      ips.sort!.each_with_index do |ip, index|
        next_ip = ips[index + 1]

        return ip if next_ip.nil? || (next_ip.to_i - ip.to_i) > 1
      end
    end
  end
end
