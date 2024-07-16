# frozen_string_literal: true

module WireGuard
  # wg show
  # In fact, the class calls only one command
  # and was created so that this command would be convenient to mock in tests.
  class StatGenerator
    def self.show
      `wg show`
    end
  end
end
