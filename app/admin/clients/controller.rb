# frozen_string_literal: true

module Admin
  module Clients
    # Main controller for managing client config files
    class Controller
      def initialize
        @wire_guard = WireGuard::Server.new
      end
    end
  end
end
