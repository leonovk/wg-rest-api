# frozen_string_literal: true

module DB # rubocop:disable Style/Documentation
  CONNECTOR = Sequel.sqlite("#{Settings.wg_path}/#{Settings.db_name}.sqlite3")

  def self.last_server_config
    CONNECTOR[:server_configs].order(Sequel.desc(:id)).first
  end

  def self.find_client_config_by_id(id)
    CONNECTOR[:client_configs].where(id: id).first
  end
end
