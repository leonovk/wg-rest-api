# frozen_string_literal: true

module Webhooks
  # Sender +_+
  class Sender
    def initialize(events)
      @events = events
    end

    def send_events
      # TODO
    end

    private

    attr_reader :events
  end
end
