# frozen_string_literal: true

module Errors
  class ConfigNotFoundError < BaseError # rubocop:disable Style/Documentation
    def message
      'The requested config was not found on the server'
    end
  end
end
