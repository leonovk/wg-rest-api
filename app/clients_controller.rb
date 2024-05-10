# frozen_string_literal: true

require_relative 'clients_serializer'

# Main controller for managing client config files
class ClientsController
  def initialize
    @wire_guard = WireGuard::Server.new
  end

  def index
    wire_guard.all_configs.to_json
  end

  def create(params)
    ClientsSerializer.serialize(wire_guard.new_config(params), wire_guard.server_public_key)
  end

  def show(id)
    config = wire_guard.config(id)

    raise Errors::ConfigNotFoundError if config.nil?

    ClientsSerializer.serialize(config, wire_guard.server_public_key)
  end

  def destroy(id)
    result = wire_guard.delete_config(id)

    raise Errors::ConfigNotFoundError if result == false

    {}.to_json
  end

  private

  attr_reader :wire_guard
end
