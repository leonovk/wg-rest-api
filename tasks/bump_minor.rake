# frozen_string_literal: true

desc 'bump minor vesrion'
task :bump_minor do
  version = File.read('VERSION').gsub('v', '').gsub("\n", '')
  semver = version.split('.')
  new_pathc = semver[1].to_i + 1
  semver[1] = new_pathc.to_s
  semver[2] = '0'
  new_version = "v#{semver.join('.')}\n"
  File.write('VERSION', new_version)
end
