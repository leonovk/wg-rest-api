# frozen_string_literal: true

# controller
class ClientsController
  def initialize
    @wire_guard = WireGuard::Server.new
  end

  def index
    wire_guard.all_configs.to_json
  end

  def create(params)
    wire_guard.new_config(params).to_json
  end

  def show(id)
    config = wire_guard.config(id)

    raise Errors::ConfigNotFoundError if config.nil?

    config.to_json
  end

  def destroy(_id)
    {}.to_json
  end

  private

  attr_reader :wire_guard
end
