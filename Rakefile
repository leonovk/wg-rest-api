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

desc 'bump minor vesrion'
task :bump_minor do
  version = File.read('VERSION').gsub('v', '')
  semver = version.split('.')
  new_pathc = semver[1].to_i + 1
  semver[1] = new_pathc.to_s
  semver[2] = '0'
  new_version = "v#{semver.join('.')}"
  File.write('VERSION', new_version)
end

desc 'print the current version'
task :version do
  puts File.read('VERSION')
end

desc 'rubocop and rspec check'
task :check do
  system 'rspec'
  system 'rubocop'
end

# rubocop:disable Rake/Desc
desc 'console'
task c: :console
task :console do
  sh 'bundle exec pry -I . -r ./app.rb'
end

desc 'start'
task :start do
  sh 'rerun puma config.ru --no-notify'
end
# rubocop:enable Rake/Desc

task default: :check
