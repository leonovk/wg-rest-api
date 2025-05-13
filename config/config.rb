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

require_relative 'application'

require_relative 'schema' unless File.exist?("#{Settings.wg_path}/#{Settings.db_name}.sqlite3")
