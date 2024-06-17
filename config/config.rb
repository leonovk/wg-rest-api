# frozen_string_literal: true

require 'config'
require 'json'
require 'rqrcode'
require 'chunky_png'
require 'tempfile'
require 'ipaddr'
require 'fileutils'
require 'ruby_units/namespaced'

env = ENV.fetch('ENVIRONMENT', 'development')

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

Config.load_and_set_settings("config/settings/#{env}.yaml")

require_relative 'application'
