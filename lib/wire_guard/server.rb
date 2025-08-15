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
      return {} if configs_empty? || @configs.nil?

      # TODO: Remove 'last_address' in future versions
      @configs.except('last_id', 'last_address')
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
      return [] if configs_empty?

      stat = ServerStat.new
      inactive_threshold = Time.now - (days * 24 * 60 * 60)
      deleted_clients = []

      all_configs.each do |id, config|
        client_stat = stat.show(config['public_key'])
        
        if client_stat.nil? || client_stat.empty? || client_stat[:last_online].nil?
          next
        end

        begin
          last_online = Time.parse(client_stat[:last_online])
          
          if last_online < inactive_threshold
            delete_config(id)
            deleted_clients << {
              id: id,
              address: config['address'],
              last_online: client_stat[:last_online]
            }
          end
        rescue ArgumentError
          # Skip clients with invalid date format
          next
        rescue Errors::ConfigNotFoundError
          # Config was already deleted, skip it
          next
        end
      end

      deleted_clients
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

    def config_address_validation!(current_id, config_params)
      configs.except('last_id', 'last_address').each do |id, config|
        raise Errors::AddressAlreadyTakenError if id != current_id and config_params['address'] == config['address']
      end
    end

    def configs_empty?
      return true if @configs.nil? || json_config.nil?
      return true if json_config['configs'].nil?
      return true if json_config['configs']['last_id'].nil?
      
      json_config['configs']['last_id'].zero?
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
