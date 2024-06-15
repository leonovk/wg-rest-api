# frozen_string_literal: true

desc 'bump pathc version'
task :bump do
  version = File.read('VERSION').gsub('v', '')
  semver = version.split('.')
  new_pathc = semver.last.to_i + 1
  semver[2] = new_pathc.to_s
  new_version = "v#{semver.join('.')}"
  File.write('VERSION', new_version)
end
