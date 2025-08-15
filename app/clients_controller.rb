# frozen_string_literal: true

# Main controller for managing client config files
class ClientsController
  def initialize
    @wire_guard = WireGuard::Server.new
  end

  def index
    ClientsSerializer.each_serialize(wire_guard.all_configs, wire_guard.server_public_key)
  end

  def create(params)
    ClientsSerializer.serialize(wire_guard.new_config(params), wire_guard.server_public_key)
  end

  def show(id)
    config = wire_guard.config(id)

    ClientsSerializer.serialize(config, wire_guard.server_public_key)
  end

  def update(id, body)
    ClientsValidator.new(body).validate!

    config = wire_guard.update_config(id, body)

    ClientsSerializer.serialize(config, wire_guard.server_public_key)
  end

  def destroy(id)
    wire_guard.delete_config(id)

    {}.to_json
  end

  def destroy_inactive(days)
    puts "DEBUG: Starting destroy_inactive with days=#{days}"
    
    begin
      deleted_clients = wire_guard.delete_inactive_configs(days.to_i)
      puts "DEBUG: Successfully got deleted_clients: #{deleted_clients}"
      
      {
        deleted_count: deleted_clients.size,
        deleted_clients: deleted_clients
      }.to_json
    rescue => e
      puts "DEBUG: Error in destroy_inactive: #{e.class} - #{e.message}"
      puts "DEBUG: Backtrace: #{e.backtrace.first(5)}"
      raise e
    end
  end

  private

  attr_reader :wire_guard
end
