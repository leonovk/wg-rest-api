# frozen_string_literal: true

module WireGuard
  class Repository # rubocop:disable Style/Documentation
    attr_reader :connection

    def initialize
      @connection = Sequel.sqlite("#{Settings.wg_path}/#{Settings.db_name}.sqlite3")
    end

    def last_server_config
      connection[:server_configs].order(Sequel.desc(:id)).first
    end

    def find_client_config_by_id(id)
      connection[:client_configs].where(id:).first
    end

    def delete_config_by_id(id)
      connection[:client_configs].where(id:).delete
    end

    def update_config_by_id(id, params)
      connection[:client_configs].where(id:).update(params)
    end

    def insert_new_config(config)
      connection[:client_configs].insert(config)
    end

    def all_client_configs
      connection[:client_configs].all
    end

    def client_stats
      connection[:client_stats].all
    end

    def find_client_stat_by_public_key(public_key)
      connection[:client_stats].where(public_key:).first
    end

    def update_client_stat_by_public_key(public_key, params)
      connection[:client_stats].where(public_key:).update(params)
    end

    def insert_server_config(private_key:, public_key:, address:, address_ipv6:)
      connection[:server_configs].insert(
        private_key:,
        public_key:,
        address:,
        address_ipv6:
      )
    end
  end
end
