# frozen_string_literal: true

module Webhooks
  # HTTP Client for Webhooks
  class Client
    include SimpleMonads

    def initialize(url)
      @connection = Faraday.new(url:)
    end

    def send_payload(payload)
      response = connection.send(:post) do |req|
        req.headers['Content-Type'] = 'application/json'
        req.body = payload.to_json
      end

      response_processing(response)
    end

    private

    attr_reader :connection

    def response_processing(response)
      if response.success?
        Success()
      else
        response_info = {
          code: response.status,
          headers: response.headers,
          message: response.body
        }

        Failure(response_info)
      end
    end
  end
end
