# frozen_string_literal: true

module Webhooks
  # Event aggregator for webhooks
  class Aggregator
    WG_STAT_PATH = "#{Settings.wg_path}/wg0_stat.json".freeze

    def initialize
      @events = []
      @new_stat_data = WireGuard::StatParser.new.parse
    end

    private

    attr_reader :events, :new_stat_data
  end
end
