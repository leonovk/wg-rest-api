# frozen_string_literal: true

module WireGuard
  # This class returns current data on WG server statistics
  class StatParser
    TIME_UNITS = {
      'day' => 86_400,
      'hour' => 3600,
      'minute' => 60,
      'second' => 1
    }.freeze

    def initialize
      @raw_data = StatGenerator.show
      @result = {}
    end

    def parse
      return {} if raw_data.nil? or raw_data.empty?

      parse_data(raw_data.split("\n"))

      result
    end

    private

    attr_reader :raw_data, :result

    def parse_data(data)
      data.each do |line|
        peer_data = line.strip.split
        parse_wg_line(peer_data)
      end
    end

    def parse_wg_line(peer_data) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      case peer_data.first
      when 'peer:'
        result[peer_data.last] = {}
        @last_peer = peer_data.last
      when 'latest'
        result[@last_peer][:last_online] = build_latest_data(peer_data)
      when 'transfer:'
        result[@last_peer][:traffic] = build_traffic_data(peer_data)
      when 'endpoint:'
        result[@last_peer][:last_ip] = build_last_ip_data(peer_data)
      end
    end

    def build_latest_data(data)
      parse_time_ago(data[2..]&.join(' ')).to_s
    end

    def build_traffic_data(data)
      {
        # rubocop:disable Style/SafeNavigationChainLength
        # TODO: Perhaps in the future it would be worthwhile to redesign this place.
        received: data[-6..-5]&.join(' ')&.to_unit&.base_scalar.to_i,
        sent: data[-3..-2]&.join(' ')&.to_unit&.base_scalar.to_i
        # rubocop:enable Style/SafeNavigationChainLength
      }
    end

    def build_last_ip_data(data)
      endpoint = data.last
      endpoint.split(':').first
    end

    def parse_time_ago(time_string)
      total_seconds = 0

      time_string.scan(/(\d+)\s+(day?|hour?|minute?|second?)/) do |value, unit|
        total_seconds += (value.to_i * TIME_UNITS[unit])
      end

      Time.now - total_seconds
    end
  end
end
