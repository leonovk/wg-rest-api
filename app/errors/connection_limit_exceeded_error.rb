# frozen_string_literal: true

module Errors
  class ConnectionLimitExceededError < BaseError # rubocop:disable Style/Documentation
    def message
      'The server connection limit has been exceeded.'
    end
  end
end
