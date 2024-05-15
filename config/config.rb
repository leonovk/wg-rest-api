# frozen_string_literal: true

require 'config'

if ENV.fetch('ENVIRONMENT', 'development') == 'development'
  begin
    require 'dotenv'
    require 'byebug'
    Dotenv.load
  rescue LoadError # rubocop:disable Lint/SuppressedException
  end
  # NOTE: in development mode, settings should be loaded after loading environment variables
  Config.load_and_set_settings('config/settings/development.yaml')
end

if ENV.fetch('ENVIRONMENT', 'development') == 'production'
  # NOTE: It is important that the settings are loaded at the beginning
  Config.load_and_set_settings('config/settings/production.yaml')

  conf = "#{Settings.wg_path}/wg0.conf"
  system('wg-quick up wg0') if File.exist?(conf)
end

require_relative '../lib/wire_guard/server'
require_relative '../app/clients_controller'
require_relative '../app/errors/config_not_found_error'
