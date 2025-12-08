# frozen_string_literal: true

module WireGuard
  # Class for obtaining statistics on traffic and last online clients
  class ServerStat
    WG_STAT_PATH = "#{Settings.wg_path}/wg0_stat.json".freeze

    attr_reader :wg_stat

    def initialize
      @last_stat_data = initialize_last_stat_data
      @new_stat_data = StatParser.new.parse
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
      new_stat_data.each do |peer, new_data|
        last_data = last_stat_data[peer]

        # NOTE: The new data will always contain the latest IP address, so we ignore it when checking.
        last_stat_data[peer] = new_data if (last_data.nil? || last_data.empty?) || !new_data.except(:last_ip).empty?
      end

      last_stat_data
    end

    def dump_stat(wg_stat)
      File.write(WG_STAT_PATH, JSON.pretty_generate(wg_stat))
    end
  end
end
