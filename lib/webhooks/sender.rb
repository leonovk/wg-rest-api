# frozen_string_literal: true

module Webhooks
  # Sender +_+
  class Sender
    def initialize(events)
      @events = events
    end

    def send_events # rubocop:disable Metrics/MethodLength
      url = Settings.webhooks_url
      return unless url

      sorted_events = sort_events
      threads = []

      sorted_events.each_value do |events|
        thread = Thread.new do
          events.each do |event|
            Client.new(url).send_payload(event)
          end
        end

        threads << thread
      end

      threads.each(&:join)
    end

    private

    attr_reader :events

    def sort_events # rubocop:disable Metrics/MethodLength
      i = 1
      result = {}

      events.compact.each do |event|
        arr = result[i]
        arr = [] if arr.nil?
        arr << event
        result[i] = arr
        if i >= 5
          i = 1
        else
          i += 1
        end
      end

      result
    end
  end
end
