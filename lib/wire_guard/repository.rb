# frozen_string_literal: true

module WireGuard
  module Repository # rubocop:disable Style/Documentation
    def last_server_config
      ::DB::CONNECTOR[:server_configs].order(Sequel.desc(:id)).first
    end

    def find_client_config_by_id(id)
      ::DB::CONNECTOR[:client_configs].where(id: id).first
    end

    def delete_config_by_id(id)
      ::DB::CONNECTOR[:client_configs].where(id: id).delete
    end

    def update_config_by_id(id, params)
      ::DB::CONNECTOR[:client_configs].where(id: id).update(params)
    end

    def insert_new_config(config)
      ::DB::CONNECTOR[:client_configs].insert(config)
    end

    def all_client_configs
      ::DB::CONNECTOR[:client_configs].all
    end

    def insert_server_config(private_key:, public_key:, address:, address_ipv6:)
      ::DB::CONNECTOR[:server_configs].insert(
        private_key:,
        public_key:,
        address:,
        address_ipv6:
      )
    end
  end
end
