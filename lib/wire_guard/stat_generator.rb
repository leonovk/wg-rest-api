# frozen_string_literal: true

module WireGuard
  # wg show
  class StatGenerator
    def self.show
      `wg show`
    rescue Errno::ENOENT
      puts 'lol kek'
    end
  end
end
