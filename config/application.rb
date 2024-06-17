# frozen_string_literal: true

Dir[File.join('./', 'app', '**', '*.rb')].each do |file|
  require file
end

Dir[File.join('./', 'lib', '**', '*.rb')].each do |file|
  require file
end
