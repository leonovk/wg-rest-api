# frozen_string_literal: true

if ENV.fetch('ENVIRONMENT', 'development') == 'development'
  begin
    require 'dotenv'
    Dotenv.load
  rescue LoadError # rubocop:disable Lint/SuppressedException
  end
end
