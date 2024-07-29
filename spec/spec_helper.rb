# frozen_string_literal: true

require 'config'
require 'json'
require 'rqrcode'
require 'chunky_png'
require 'tempfile'
require 'ipaddr'
require 'fileutils'
require 'ruby_units/namespaced'
require 'byebug'
require 'json-schema'

Config.load_and_set_settings('config/settings/test.yaml')

require_relative '../config/application'

def sentry?
  false
end

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

def stringify_keys(data)
  data.is_a?(Hash) ? data.to_h { |k, v| [k.to_s, stringify_keys(v)] } : data
end
