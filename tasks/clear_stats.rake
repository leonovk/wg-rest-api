# frozen_string_literal: true

require 'fileutils'
require 'json'

desc 'clear stats'
task :clear_stats do
  path = "#{Settings.wg_path}/wg0_stat.json"

  FileUtils.mkdir_p(Settings.wg_path)

  File.write(path, {}.to_json)
end
