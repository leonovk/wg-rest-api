# frozen_string_literal: true

require_relative 'dependencies'

env = ENV.fetch('ENVIRONMENT', 'development')
Config.load_and_set_settings("config/settings/#{env}.yaml")

if env == 'development'
  begin
    require 'dotenv'
    require 'byebug'
    Dotenv.load
  rescue LoadError # rubocop:disable Lint/SuppressedException
  end
elsif env == 'production'
  conf = "#{Settings.wg_path}/wg0.conf"
  system('wg-quick up wg0') if File.exist?(conf)
end

FileUtils.mkdir_p(Settings.wg_path)

if File.exist?("#{Settings.wg_path}/wg-rest-api-db.sqlite3")
  require_relative 'db' # rubocop:disable Style/IdenticalConditionalBranches
else
  # NOTE: Very important: `require_relative 'db'` creates a file with an empty database if it does not exist
  # Therefore, if the file did not exist initially and we have created it now,
  # only in this case we roll out the data scheme.
  require_relative 'db' # rubocop:disable Style/IdenticalConditionalBranches
  require_relative 'schema'
end

require_relative 'application'
