# frozen_string_literal: true

require_relative 'show'

module WireGuard
  # class return server stat
  class ServerStat
    attr_reader :wg_stat

    def initialize
      @wg_stat = parse(Show.show)
    end

    def show(peer)
      return {} if wg_stat.empty?

      wg_stat[peer]
    end

    private

    def parse(wg_stat)
      return {} if wg_stat.empty?

      parse_data(wg_stat.split("\n"))
    end

    def parse_data(data) # rubocop:disable Metrics/MethodLength
      last_peer = nil
      result = {}
      data.each do |line|
        peer_dara = line.strip.split

        case peer_dara.first
        when 'peer:'
          result[peer_dara.last] = {}
          last_peer = peer_dara.last
        when 'latest'
          result[last_peer][:last_online] = build_latest_data(peer_dara)
        when 'transfer:'
          result[last_peer][:trafik] = build_trafic_data(peer_dara)
        end
      end
      result
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
