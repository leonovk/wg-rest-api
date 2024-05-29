# frozen_string_literal: true

require 'json'
require 'byebug'
require 'config'
require 'fileutils'
Config.load_and_set_settings('config/settings/test.yaml')

require_relative '../app/clients_serializer'
require_relative '../app/clients_controller'
require_relative '../app/clients_validator'
require_relative '../lib/wire_guard/server'
require_relative '../lib/wire_guard/server_stat'
require_relative '../lib/wire_guard/config_builder'
require_relative '../lib/wire_guard/config_updater'
require_relative '../app/errors/config_not_found_error'
require_relative '../app'

require 'super_diff/rspec'
require 'rack/test'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'

  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def create_conf_file(from, wg_conf_path = "#{Settings.wg_path}/wg0.json")
  FileUtils.mkdir_p(Settings.wg_path)
  FileUtils.cp(from, wg_conf_path)
end
