# frozen_string_literal: true

require 'rubygems'
require 'zip'

desc 'create backup'
task :create_backup do
  folder = Settings.wg_path
  input_filenames = ['wg0.json', 'wg0_stat.json']
  zipfile_name = "#{Settings.wg_path}/backup-#{Time.now}.zip"

  Zip::File.open(zipfile_name, create: true) do |zipfile|
    input_filenames.each do |filename|
      zipfile.add(filename, File.join(folder, filename))
    end
  end
end
