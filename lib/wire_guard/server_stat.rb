# frozen_string_literal: true

require_relative 'stat_generator'
require 'fileutils'
require 'ruby_units/namespaced'

module WireGuard
  # Class for obtaining statistics on traffic and last online clients
  class ServerStat
    WG_STAT_PATH = "#{Settings.wg_path}/wg0_stat.json".freeze

    attr_reader :wg_stat

    def initialize
      @last_stat_data = initialize_last_stat_data
      @new_stat_data = parse(StatGenerator.show)
      @wg_stat = aggregate_data
      dump_stat(@wg_stat)
    end

    def show(peer)
      return {} if wg_stat.empty?

      wg_stat[peer]
    end

    private

    attr_reader :last_stat_data, :new_stat_data, :last_peer

    def initialize_last_stat_data
      FileUtils.mkdir_p(Settings.wg_path)

      if File.exist?(WG_STAT_PATH)
        JSON.parse(File.read(WG_STAT_PATH))
      else
        {}
      end
    end

    def aggregate_data
      new_stat_data.each do |peer, data|
        last_data = last_stat_data[peer]

        if last_data.nil? || last_data.empty?
          last_stat_data[peer] = data
        else
          # NOTE: Because of this, the final result may contain character keys and string keys.
          # If the data is taken from a file.
          # TODO: To fix this. We need to come up with a concise solution.
          next if data.empty?

          last_stat_data[peer] = increment_data(data, last_data)
        end
      end

      # NOTO: It may not be the best solution to enrich a hash with old data with new data.
      # It might be worth changing it to generate a new hash.
      # This will probably solve the problem from TODO above
      last_stat_data
    end

    def increment_data(new_data, last_data)
      {
        last_online: new_data[:last_online],
        trafik: increment_trafik(new_data[:trafik], last_data['trafik'])
      }
    end

    def increment_trafik(new_trafik, last_trafik)
      {
        received: sum_trafic(new_trafik[:received], last_trafik['received']),
        sent: sum_trafic(new_trafik[:sent], last_trafik['sent'])
      }
    end

    def dump_stat(wg_stat)
      File.write(WG_STAT_PATH, JSON.pretty_generate(wg_stat))
    end

    def parse(wg_stat)
      return {} if wg_stat.empty?

      parse_data(wg_stat.split("\n"))

      @result
    end

    def parse_data(data)
      @result = {}

      data.each do |line|
        peer_data = line.strip.split
        parse_wg_line(peer_data)
      end
    end

    def parse_wg_line(peer_data)
      case peer_data.first
      when 'peer:'
        @result[peer_data.last] = {}
        @last_peer = peer_data.last
      when 'latest'
        @result[last_peer][:last_online] = build_latest_data(peer_data)
      when 'transfer:'
        @result[last_peer][:trafik] = build_trafic_data(peer_data)
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

    def sum_trafic(first, second)
      result = first.to_unit + second.to_unit
      result.convert_to('GiB').round(2).to_s
    end
  end
end
