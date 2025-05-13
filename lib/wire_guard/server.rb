# frozen_string_literal: true

module WireGuard
  # Main class for WireGuard server management
  # Allows you to manage configuration files on the server
  class Server
    WG_DEFAULT_ADDRESS = Settings.wg_default_address.gsub('x', '1')
    WG_DEFAULT_ADDRESS_6 = Settings.wg_default_address_6.gsub('x', '1')

    attr_reader :server_private_key, :server_public_key, :server_config, :configs

    def initialize
      initialize_server_config
    end

    def new_config(params)
      config = build_new_config(configs, params)

      config[:id] = DB::CONNECTOR[:client_configs].insert(config)

      dump_wireguard_config

      config
    end

    def config(id)
      configs_empty_validation!

      DB.find_client_config_by_id(id) or raise Errors::ConfigNotFoundError
    end

    def delete_config(id)
      configs_empty_validation!

      result = DB::CONNECTOR[:client_configs].where(id: id).delete

      raise Errors::ConfigNotFoundError if result.zero?

      dump_wireguard_config
    end

    def update_config(id, config_params)
      configs_empty_validation!

      updatable_config = DB.find_client_config_by_id(id)

      raise Errors::ConfigNotFoundError if updatable_config.nil?

      updated_config = merge_config(updatable_config, config_params.transform_keys(&:to_sym))

      DB::CONNECTOR[:client_configs].where(id: id).update(updated_config)
      dump_wireguard_config

      updated_config
    end

    private

    def initialize_server_config
      if DB.last_server_config.nil?
        generate_server_private_key
        generate_server_public_key
        create_server_config
      else
        initialize_data
      end
    end

    def initialize_data
      @server_config = DB.last_server_config
      @server_private_key = @server_config[:private_key]
      @server_public_key = @server_config[:public_key]
      @configs = DB::CONNECTOR[:client_configs].all
    end

    def create_server_config
      DB::CONNECTOR[:server_configs].insert(
        private_key: @server_private_key,
        public_key: @server_public_key,
        address: WG_DEFAULT_ADDRESS,
        address_ipv6: WG_DEFAULT_ADDRESS_6
      )

      @server_config = DB.last_server_config
    end

    def dump_wireguard_config
      ServerConfigUpdater.update
    end

    def generate_server_private_key
      @server_private_key = KeyGenerator.wg_genkey
    end

    def generate_server_public_key
      @server_public_key = KeyGenerator.wg_pubkey(@server_private_key)
    end

    def configs_empty_validation!
      raise Errors::ConfigNotFoundError if configs.empty?
    end

    def build_new_config(configs, params)
      ClientConfigBuilder.new(configs, params).config
    end

    def merge_config(updatable_config, config_params)
      updatable_config[:data] = JSON.parse(updatable_config[:data])
      config = updatable_config.merge(config_params)

      if !config_params[:data].nil? && config_params[:data].any?
        config[:data] = updatable_config[:data].merge(config_params[:data]).to_json
      end

      config
    end
  end
end
