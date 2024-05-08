# frozen_string_literal: true

module WireGuard
  # kg
  class KeyGenerator
    class << self
      def wg_genkey
        `wg genkey`.gsub(/\n$/, '')
      end

      def wg_pubkey(wg_genkey)
        `echo #{wg_genkey} | wg pubkey`.gsub(/\n$/, '')
      end

      def wg_genpsk
        `wg genpsk`.gsub(/\n$/, '')
      end
    end
  end
end
