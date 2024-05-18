# frozen_string_literal: true

require_relative 'base_error'

module Errors
  class ConfigNotFoundError < BaseError # rubocop:disable Style/Documentation
    def message
      'The requested config was not found on the server'
    end
  end
end
