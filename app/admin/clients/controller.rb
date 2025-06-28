# frozen_string_literal: true

module Admin
  module Clients
    # Main controller for managing client config files
    class Controller
      def initialize
        @wire_guard = WireGuard::Server.new
      end

      def clients
        {
          server_public_key: wire_guard.server_public_key,
          clients: wire_guard.all_configs
        }
      end

      private

      attr_reader :wire_guard
    end
  end
end
