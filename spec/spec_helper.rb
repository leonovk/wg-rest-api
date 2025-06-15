# frozen_string_literal: true

require_relative '../config/dependencies'
require 'byebug'

Config.load_and_set_settings('config/settings/test.yaml')

require 'simplecov'

SimpleCov.start

require_relative '../config/application'

FileUtils.mkdir_p(Settings.wg_path)

require_relative '../config/schema' unless File.exist?("#{Settings.wg_path}/#{Settings.db_name}.sqlite3")

def sentry?
  false
end

require_relative '../app'
require_relative 'factories/base_factory'
require_relative 'factories/server_config'
require_relative 'factories/client_config'

require 'super_diff/rspec'
require 'rack/test'
require 'webmock/rspec'
require 'timecop'

RSpec.configure do |config|
  ENV['TZ'] = 'UTC'
  config.example_status_persistence_file_path = '.rspec_status'

  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def clear_all_tables
  rep = WireGuard::Repository.new

  %i[server_configs client_configs client_stats client_events].each do |table|
    rep.connection[table].delete
  end
end

clear_all_tables
