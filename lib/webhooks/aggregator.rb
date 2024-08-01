# frozen_string_literal: true

module Webhooks
  # Event aggregator for webhooks
  class Aggregator
    attr_reader :events

    def initialize
      @events = []
      @new_stat_data = WireGuard::StatParser.new.parse
      @last_stat_data = initialize_last_stat_data
      aggregate_events
      WireGuard::ServerStat.new
    end

    private

    attr_reader :new_stat_data, :last_stat_data

    def aggregate_events
      new_stat_data.each do |peer, new_data|
        # TODO
      end
    end

    def initialize_last_stat_data
      FileUtils.mkdir_p(Settings.wg_path)

      if File.exist?(WireGuard::ServerStat::WG_STAT_PATH)
        JSON.parse(File.read(WireGuard::ServerStat::WG_STAT_PATH))
      else
        {}
      end
    end
  end
end
