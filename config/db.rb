# frozen_string_literal: true

module DB
  CONNECTOR = Sequel.sqlite("#{Settings.wg_path}/wg-rest-api-db.sqlite3")
end
