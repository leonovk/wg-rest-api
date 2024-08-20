# frozen_string_literal: true

module Webhooks
  # The class sends events in multi-threaded mode
  class Sender
    BATCH_SIZE = 8
    URL = Settings.webhooks_url

    def initialize(events)
      @events = events
      @threads = []
    end

    def send_events
      return unless URL

      events.compact.each_slice(BATCH_SIZE) do |events_batch|
        thread = Thread.new do
          events_batch.each do |event|
            Client.new(URL).send_payload(event)
          end
        end

        threads << thread
      end

      threads.each(&:join)
    end

    private

    attr_reader :events, :threads
  end
end
