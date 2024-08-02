# frozen_string_literal: true

module Webhooks
  # Event aggregator for webhooks
  class Aggregator
    WG_EVENTS_PATH = "#{Settings.wg_path}/wg0_events.json".freeze

    attr_reader :events

    def initialize
      @events = []
      @new_stat_data = WireGuard::StatParser.new.parse
      @last_stat_data = initialize_last_stat_data
      @last_events_data = initialize_last_event_data
      aggregate_events
      WireGuard::ServerStat.new
      dump_events
    end

    private

    attr_reader :new_stat_data, :last_stat_data, :last_events_data

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def aggregate_events
      new_stat_data.each do |peer, new_data|
        last_data = last_stat_data[peer]
        last_event = last_events_data[peer]

        if (last_data.nil? || last_data.empty?) && !new_data.empty?
          events << build_event(peer, Events::CONNECTED)
        elsif !last_data.nil? && last_data.any? && new_data.any?
          event = calculate_event(last_data, new_data, last_event)
          last_events_data[peer] = event unless event.nil?
          events << build_event(peer, event)
        end
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def calculate_event(last_data, new_data, last_event)
      new_data_sum = new_data[:traffic][:received].to_unit + new_data[:traffic][:sent].to_unit
      last_data_sum = last_data['traffic']['received'].to_unit + last_data['traffic']['sent'].to_unit

      if new_data_sum > last_data_sum
        last_event == Events::CONNECTED ? nil : Events::CONNECTED
      elsif new_data_sum == last_data_sum
        last_event == Events::CONNECTED ? Events::DISCONNECTED : nil
      end
    end

    def build_event(peer, event)
      return if event.nil?

      { peer:, event: }
    end

    def initialize_last_stat_data
      FileUtils.mkdir_p(Settings.wg_path)

      if File.exist?(WireGuard::ServerStat::WG_STAT_PATH)
        JSON.parse(File.read(WireGuard::ServerStat::WG_STAT_PATH))
      else
        {}
      end
    end

    def initialize_last_event_data
      if File.exist?(WG_EVENTS_PATH)
        JSON.parse(File.read(WG_EVENTS_PATH))
      else
        {}
      end
    end

    def dump_events
      File.write(WG_EVENTS_PATH, JSON.pretty_generate(last_events_data))
    end
  end
end
