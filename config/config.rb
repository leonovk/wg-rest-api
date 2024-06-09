# frozen_string_literal: true

require 'config'
require 'json'

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

def sentry?
  ENV.fetch('SENTRY_DSN', nil) and ENV.fetch('ENVIRONMENT', 'development') == 'production'
end

require_relative 'sentry' if sentry?

require_relative '../lib/wire_guard/server'
require_relative '../lib/wire_guard/server_stat'
require_relative '../app/clients_controller'
require_relative '../app/errors/config_not_found_error'
require_relative '../lib/utils/config_file_builder'
require_relative '../lib/utils/qr_code_builder'
