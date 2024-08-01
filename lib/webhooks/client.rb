# frozen_string_literal: true

module Webhooks
  # HTTP Client for Webhooks
  class Client
    def initialize(url)
      @connection = Faraday.new(url:)
    end

    def send_payload(payload)
      connection.send(:post) do |req|
        req.headers['Content-Type'] = 'application/json'
        req.body = payload.to_json
      end
    end

    private

    attr_reader :connection
  end
end
