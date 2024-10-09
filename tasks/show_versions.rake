# frozen_string_literal: true

desc 'print the current version'
task :version do
  puts File.read('VERSION').gsub("\n", '')
end
