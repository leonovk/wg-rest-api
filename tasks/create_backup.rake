# frozen_string_literal: true

require 'rubygems'
require 'zip'
require 'byebug'
require 'rainbow/refinement'
using Rainbow

desc 'create backup'
task :create_backup do
  folder = Settings.wg_path
  input_filenames = ['wg0.json', 'wg0_stat.json', 'wg0.conf']
  FileUtils.mkdir_p("#{folder}/backups")
  zipfile_name = "#{folder}/backups/backup-#{Time.now.iso8601}.zip"

  Zip::File.open(zipfile_name, create: true) do |zipfile|
    input_filenames.each do |filename|
      zipfile.add(filename, File.join(folder, filename)) if File.exist?(File.join(folder, filename))
    end
  end

  print 'the backup was saved: '
  puts zipfile_name.green
end
