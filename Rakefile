# frozen_string_literal: true

require 'rake/tasklib'
require 'byebug'

require_relative 'config/dependencies'

env = ENV.fetch('ENVIRONMENT', 'development')

if env == 'development'
  begin
    require 'dotenv'
    Dotenv.load
  rescue LoadError # rubocop:disable Lint/SuppressedException
  end
end

Config.load_and_set_settings("config/settings/#{env}.yaml")

require_relative 'config/application'

Dir.glob('tasks/*.rake').each do |file|
  load file
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
  sh 'bundle exec pry -I . -r ./config/config.rb'
end

desc 'start'
task :start do
  sh 'rerun puma config.ru --no-notify'
end
# rubocop:enable Rake/Desc

task default: :check
