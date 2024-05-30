# frozen_string_literal: true

require_relative 'stat_generator'

module WireGuard
  # class return server stat
  class ServerStat
    attr_reader :wg_stat

    def initialize
      @result = {}
      @last_peer = nil
      @wg_stat = parse(StatGenerator.show)
    end

    def show(peer)
      return {} if wg_stat.empty?

      wg_stat[peer]
    end

    private

    attr_reader :result, :last_peer

    def parse(wg_stat)
      return {} if wg_stat.empty?

      parse_data(wg_stat.split("\n"))

      result
    end

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
        result[last_peer][:last_online] = build_latest_data(peer_data)
      when 'transfer:'
        result[last_peer][:trafik] = build_trafic_data(peer_data)
      end
    end

    def build_latest_data(data)
      data[-3..]&.join(' ')
    end

    def build_trafic_data(data)
      {
        received: data[-6..-5]&.join(' '),
        sent: data[-3..-2]&.join(' ')
      }
    end
  end
end
