# frozen_string_literal: true

module Server
  # server controller
  class Controller
    def initialize
      @wire_guard = WireGuard::Server.new
    end

    def show
      Serializer.new.serialize(wire_guard.json_config)
    end

    private

    attr_reader :wire_guard
  end
end
