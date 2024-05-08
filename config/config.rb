# frozen_string_literal: true

require 'config'

if ENV.fetch('ENVIRONMENT', 'development') == 'development'
  begin
    require 'dotenv'
    require 'byebug'
    Dotenv.load
  rescue LoadError # rubocop:disable Lint/SuppressedException
  end
end

Config.load_and_set_settings('config/settings.yaml')

if ENV.fetch('ENVIRONMENT', 'development') == 'production'
  conf = "#{Settings.wg_path}/wg0.conf"
  system('wg-quick up wg0') if File.exist?(conf)
end

require_relative '../lib/wire_guard/server'
require_relative '../app/clients_controller'
require_relative '../app/errors/config_not_found_error'
