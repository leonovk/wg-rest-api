# frozen_string_literal: true

module WireGuard
  # cu
  class ConfigUpdater
    WG_CONF_PATH = "#{Settings.wg_path}/wg0.conf".freeze
    WG_PORT = Settings.wg_port

    def initialize
      @json_config = JSON.parse(File.read(WireGuard::Server::WG_JSON_PATH))
      # system('wg-quick down wg0') if File.exist?(WG_CONF_PATH)
      # generate_base_config
    end

    def self.update
      new.update
    end

    def update; end

    private

    attr_reader :json_config, :base_config
  end
end
