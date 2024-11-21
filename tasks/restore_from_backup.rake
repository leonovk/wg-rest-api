# frozen_string_literal: true

require 'rubygems'
require 'zip'

desc 'restore from backup'
task :restore_from_backup, [:backup_path] do |_t, args|
  raise 'Empty backup path' if args[:backup_path].nil?

  zip_file_path = args[:backup_path]
  destination_folder = Settings.wg_path

  Zip::File.open(zip_file_path) do |zip_file|
    zip_file.each do |entry|
      filename = File.join(destination_folder, entry.name)

      FileUtils.rm_rf(filename)

      entry.extract(filename)
    end
  end

  puts "All files were successfully extracted in #{destination_folder}."
end
