# frozen_string_literal: true

module WireGuard
  # Main class for WireGuard server management
  # Allows you to manage configuration files on the server
  class Server
    WG_JSON_PATH = "#{Settings.wg_path}/wg0.json".freeze
    WG_DEFAULT_ADDRESS = Settings.wg_default_address.gsub('x', '1')

    attr_reader :server_private_key, :server_public_key

    def initialize
      initialize_json_config
    end

    def new_config(params)
      config = build_new_config(json_config['configs'], params)

      update_json_config(config)
      dump_json_config(json_config)
      dump_wireguard_config

      config
    end

    def all_configs
      return {} if configs_empty?

      @configs.except('last_id')
    end

    def config(id)
      configs_empty_validation!

      @configs[id] or raise Errors::ConfigNotFoundError
    end

    def delete_config(id)
      configs_empty_validation!

      result = json_config['configs'].delete(id)

      raise Errors::ConfigNotFoundError if result.nil?

      dump_json_config(json_config)
      dump_wireguard_config
    end

    def update_config(id, config_params)
      configs_empty_validation!

      updated_config = json_config['configs'][id]

      raise Errors::ConfigNotFoundError if updated_config.nil?

      json_config['configs'][id] = merge_config(updated_config, config_params)

      dump_json_config(json_config)
      dump_wireguard_config

      json_config['configs'][id]
    end

    private

    attr_reader :json_config

    def initialize_json_config
      FileUtils.mkdir_p(Settings.wg_path)

      if File.exist?(WG_JSON_PATH)
        initialize_data
      else
        generate_server_private_key
        generate_server_public_key
        create_json_server_config
      end
    end

    def initialize_data
      @json_config = JSON.parse(File.read(WG_JSON_PATH))
      @server_private_key = @json_config['server']['private_key']
      @server_public_key = @json_config['server']['public_key']
      @configs = @json_config['configs']
    end

    def create_json_server_config # rubocop:disable Metrics/MethodLength
      json_config = {
        server: {
          private_key: @server_private_key,
          public_key: @server_public_key,
          address: WG_DEFAULT_ADDRESS
        },
        configs: {
          last_id: 0
        }
      }

      dump_json_config(json_config)
      # NOTE: Сreate their hash above a new Jason file
      # and read the result and write it to an instant variable.
      # So as not to turn all the keys into strings.
      @json_config = JSON.parse(File.read(WG_JSON_PATH))
    end

    def dump_json_config(config)
      File.write(WG_JSON_PATH, JSON.pretty_generate(config))
    end

    def dump_wireguard_config
      ServerConfigUpdater.update
    end

    def update_json_config(config)
      json_config['configs'][config[:id].to_s] = config
      json_config['configs']['last_id'] = config[:id]
    end

    def generate_server_private_key
      @server_private_key = KeyGenerator.wg_genkey
    end

    def generate_server_public_key
      @server_public_key = KeyGenerator.wg_pubkey(@server_private_key)
    end

    def configs_empty_validation!
      raise Errors::ConfigNotFoundError if configs_empty?
    end

    def configs_empty?
      @configs.nil? or json_config['configs']['last_id'].zero?
    end

    def build_new_config(configs, params)
      ClientConfigBuilder.new(configs, params).config
    end

    def merge_config(updated_config, config_params)
      config = updated_config.merge(config_params)
      if !config_params['data'].nil? && config_params['data'].any?
        config['data'] = updated_config['data'].merge(config_params['data'])
      end

      config
    end
  end
end
