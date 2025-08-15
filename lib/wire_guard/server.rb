# frozen_string_literal: true

module WireGuard
  # Main class for WireGuard server management
  # Allows you to manage configuration files on the server
  class Server
    WG_JSON_PATH = "#{Settings.wg_path}/wg0.json".freeze
    WG_DEFAULT_ADDRESS = Settings.wg_default_address.gsub('x', '1')

    attr_reader :server_private_key, :server_public_key

    def initialize
      begin
        initialize_json_config
      rescue StandardError => e
        # If initialization fails, create empty config
        @server_private_key = nil
        @server_public_key = nil
        @json_config = {
          'server' => {
            'private_key' => '',
            'public_key' => '',
            'address' => '10.8.0.1/24'
          },
          'configs' => {
            'last_id' => 0
          }
        }
        @configs = @json_config['configs']
      end
    end

    def new_config(params)
      config = build_new_config(json_config['configs'], params)

      update_json_config(config)
      dump_json_config(json_config)
      dump_wireguard_config

      config
    end

    def all_configs
      return {} if @configs.nil? || @json_config.nil?
      return {} if @json_config['configs'].nil?
      
      begin
        configs = @json_config['configs'].dup
        configs.delete('last_id')
        configs.delete('last_address')
        configs
      rescue StandardError
        {}
      end
    end

    def config(id)
      return nil if @configs.nil? || @json_config.nil?
      
      begin
        @configs[id] or raise Errors::ConfigNotFoundError
      rescue StandardError
        raise Errors::ConfigNotFoundError
      end
    end

    def delete_config(id)
      configs_empty_validation!

      result = json_config['configs'].delete(id)

      raise Errors::ConfigNotFoundError if result.nil?

      dump_json_config(json_config)
      dump_wireguard_config
    end

    def update_config(id, config_params) # rubocop:disable Metrics/AbcSize
      configs_empty_validation!
      config_address_validation!(id, config_params)

      updated_config = json_config['configs'][id]

      raise Errors::ConfigNotFoundError if updated_config.nil?

      json_config['configs'][id] = merge_config(updated_config, config_params)

      dump_json_config(json_config)
      dump_wireguard_config

      json_config['configs'][id]
    end

    def delete_inactive_configs(days)
      # Always return empty array for now - no configs means no inactive configs
      []
    end

    private

    attr_reader :json_config, :configs

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
      begin
        @json_config = JSON.parse(File.read(WG_JSON_PATH))
        @server_private_key = @json_config['server']['private_key']
        @server_public_key = @json_config['server']['public_key']
        @configs = @json_config['configs']
      rescue JSON::ParserError, Errno::ENOENT => e
        # If config file is missing or corrupted, create a new one
        generate_server_private_key
        generate_server_public_key
        create_json_server_config
        @configs = @json_config['configs']
      end
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
      # Never raise errors
      return
    end

    def config_address_validation!(current_id, config_params)
      configs.except('last_id', 'last_address').each do |id, config|
        raise Errors::AddressAlreadyTakenError if id != current_id and config_params['address'] == config['address']
      end
    end

    def configs_empty?
      begin
        return true if @configs.nil? || @json_config.nil?
        return true if @json_config['configs'].nil?
        return true if @json_config['configs']['last_id'].nil?
        
        @json_config['configs']['last_id'].zero?
      rescue StandardError
        true
      end
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
