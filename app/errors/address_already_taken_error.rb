# frozen_string_literal: true

module Errors
  class AddressAlreadyTakenError < BaseError # rubocop:disable Style/Documentation
    def message
      'The address is already in use by another client'
    end
  end
end
