# frozen_string_literal: true

module Webhooks
  # The class sends events in multi-threaded mode
  class Sender
    MAX_THREADS = 8
    URL = Settings.webhooks_url

    def initialize(events)
      @events = events
      @threads = []
    end

    def send_events
      return unless URL

      sort_events.each_value do |events|
        thread = Thread.new do
          events.each do |event|
            Client.new(URL).send_payload(event)
          end
        end

        threads << thread
      end

      threads.each(&:join)
    end

    private

    attr_reader :events, :threads

    def sort_events
      i = 1
      result = {}

      events.compact.each do |event|
        arr = result[i]
        arr = [] if arr.nil?
        arr << event
        result[i] = arr
        i >= MAX_THREADS ? i = 1 : i += 1
      end

      result
    end
  end
end
