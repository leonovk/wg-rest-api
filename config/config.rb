# frozen_string_literal: true

if ENV.fetch('ENVIRONMENT', 'development') == 'development'
  require 'dotenv'
  Dotenv.load
end
