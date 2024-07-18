# frozen_string_literal: true

module Utils
  # class that from Jason's config creates a ready-made config for the end user
  class ConfigFileBuilder
    def self.build(config)
      new(config).build
    end

    def initialize(config)
      @key = JSON.parse(config)
    end

    def build
      "#{interface}\n#{peer}"
    end

    private

    def interface
      result = <<~TEXT
        [Interface]
        PrivateKey = #{key['private_key']}
        Address = #{key['address']}
      TEXT
      result << "DNS = #{key['dns']}\n" if key['dns']
      result
    end

    def peer
      <<~TEXT
        [Peer]
        PublicKey = #{key['server_public_key']}
        PresharedKey = #{key['preshared_key']}
        AllowedIPs = #{key['allowed_ips']}
        PersistentKeepalive = #{key['persistent_keepalive']}
        Endpoint = #{key['endpoint']}
      TEXT
    end

    attr_reader :key
  end
end
