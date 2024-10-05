# frozen_string_literal: true

module WireGuard
  # The class generates a config file for the client
  class ClientConfigBuilder
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
        id: new_last_id,
        address: new_last_ip,
        private_key: wg_genkey,
        public_key: wg_pubkey,
        preshared_key: wg_genpsk,
        enable: true,
        data: params
      }
    end

    def new_last_id
      configs['last_id'] + 1
    end

    def new_last_ip
      current_ip = IPAddr.new(configs['last_address'])
      IPAddr.new(current_ip.to_i + 1, Socket::AF_INET).to_s
    end
  end
end
