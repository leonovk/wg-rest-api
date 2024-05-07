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
