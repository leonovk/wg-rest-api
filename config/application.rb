# frozen_string_literal: true

require './app/errors/base_error'

Dir[File.join('./', 'app', '**', '*.rb')].each do |file|
  require file
end

Dir[File.join('./', 'lib', '**', '*.rb')].each do |file|
  require file
end
