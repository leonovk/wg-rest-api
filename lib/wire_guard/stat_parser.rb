# frozen_string_literal: true

module WireGuard
  # This class returns current data on WG server statistics
  class StatParser
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

    def parse_wg_line(peer_data)
      case peer_data.first
      when 'peer:'
        result[peer_data.last] = {}
        @last_peer = peer_data.last
      when 'latest'
        result[@last_peer][:last_online] = build_latest_data(peer_data)
      when 'transfer:'
        result[@last_peer][:traffic] = build_traffic_data(peer_data)
      end
    end

    def build_latest_data(data)
      data[2..]&.join(' ')
    end

    def build_traffic_data(data)
      {
        received: data[-6..-5]&.join(' '),
        sent: data[-3..-2]&.join(' ')
      }
    end
  end
end
