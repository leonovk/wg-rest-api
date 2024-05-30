# frozen_string_literal: true

module WireGuard
  # wg show
  class StatGenerator
    def self.show
      `wg show`
    end
  end
end
