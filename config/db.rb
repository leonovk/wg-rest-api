# frozen_string_literal: true

module DB
  CONNECTOR = Sequel.sqlite("#{Settings.wg_path}/#{Settings.db_name}.sqlite3")
end
