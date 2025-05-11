# frozen_string_literal: true

module Clients
  # class for validating input data from the user
  class Validator
    attr_accessor :params

    SCHEMA = {
      'type' => 'object',
      'properties' => {
        'address' => { 'type' => 'string' },
        'address_ipv6' => { 'type' => 'string' },
        'private_key' => { 'type' => 'string' },
        'public_key' => { 'type' => 'string' },
        'preshared_key' => { 'type' => 'string' },
        'enable' => { 'type' => 'boolean' },
        'data' => { 'type' => 'object' }
      },
      'additionalProperties' => false
    }.freeze

    def initialize(params)
      @params = params
    end

    def validate!
      JSON::Validator.validate!(SCHEMA, params)
    end
  end
end
