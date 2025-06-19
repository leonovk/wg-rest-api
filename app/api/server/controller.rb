# frozen_string_literal: true

module Api
  module Server
    # server controller
    class Controller
      def initialize
        @wire_guard = WireGuard::Server.new
      end

      def show
        Serializer.serialize(wire_guard.json_config)
      end

      private

      attr_reader :wire_guard
    end
  end
end
