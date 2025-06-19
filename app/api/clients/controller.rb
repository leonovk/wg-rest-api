# frozen_string_literal: true

module Api
  module Clients
    # Main controller for managing client config files
    class Controller
      def initialize
        @wire_guard = WireGuard::Server.new
      end

      def index
        Serializer.each_serialize(wire_guard.all_configs, wire_guard.server_public_key)
      end

      def create(params)
        Serializer.serialize(wire_guard.new_config(params), wire_guard.server_public_key)
      end

      def show(id)
        config = wire_guard.config(id)

        Serializer.serialize(config, wire_guard.server_public_key)
      end

      def update(id, body)
        Validator.new(body).validate!

        config = wire_guard.update_config(id, body)

        Serializer.serialize(config, wire_guard.server_public_key)
      end

      def destroy(id)
        wire_guard.delete_config(id)

        {}.to_json
      end

      private

      attr_reader :wire_guard
    end
  end
end
