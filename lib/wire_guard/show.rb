# frozen_string_literal: true

module WireGuard
  # wg show
  class Show
    def self.show
      `wg show`
    end
  end
end
