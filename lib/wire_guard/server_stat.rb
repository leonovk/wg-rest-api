# frozen_string_literal: true

require_relative 'stat_generator'
require 'fileutils'

module WireGuard
  # class return server stat
  class ServerStat
    WG_STAT_PATH = "#{Settings.wg_path}/wg0_stat.json".freeze

    attr_reader :wg_stat

    def initialize
      @result = {}
      @last_peer = nil
      @wg_stat = parse(StatGenerator.show)
      dump_stat(wg_stat)
    end

    def show(peer)
      return {} if wg_stat.empty?

      wg_stat[peer]
    end

    private

    attr_reader :result, :last_peer

    def dump_stat(wg_stat)
      FileUtils.mkdir_p(Settings.wg_path)

      if File.exist?(WG_STAT_PATH)
        json_stat = JSON.parse(File.read(WG_STAT_PATH))
        wg_stat.each do |peer, data|
          json_stat[peer] = data
        end
        File.write(WG_STAT_PATH, JSON.pretty_generate(json_stat))
      else
        File.write(WG_STAT_PATH, JSON.pretty_generate(wg_stat))
      end
    end

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
