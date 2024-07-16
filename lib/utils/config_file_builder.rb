# frozen_string_literal: true

module Utils
  # class that from JSON config creates a ready-made config for the end user
  class ConfigFileBuilder
    def self.build(config)
      new(config).build
    end

    def initialize(config)
      @key = JSON.parse(config)
    end

    def build
      <<~TEXT
        [Interface]
        PrivateKey = #{key['private_key']}
        Address = #{key['address']}
        DNS = #{key['dns']}

        [Peer]
        PublicKey = #{key['server_public_key']}
        PresharedKey = #{key['preshared_key']}
        AllowedIPs = #{key['allowed_ips']}
        PersistentKeepalive = #{key['persistent_keepalive']}
        Endpoint = #{key['endpoint']}
      TEXT
    end

    private

    attr_reader :key
  end
end
