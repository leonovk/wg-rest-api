# frozen_string_literal: true

require_relative '../lib/wire_guard/server_stat'
require 'json'

desc 'update stats'
task :update_stats do
  WireGuard::ServerStat.new
end
