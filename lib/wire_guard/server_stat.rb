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
      new_stat_data.each do |peer, data|
        last_data = last_stat_data[peer]

        # NOTE: If there is no latest data, then we write down new ones in any case,
        # even if they are not there.
        if last_data.nil? or last_data.empty?
          last_stat_data[peer] = data
        elsif !data.empty?
          last_stat_data[peer] = increment_data(data, last_data)
        end
      end

      last_stat_data
    end

    def increment_data(new_data, last_data)
      {
        last_online: new_data[:last_online],
        traffic: increment_traffic(new_data[:traffic], last_data['traffic'])
      }
    end

    def increment_traffic(new_traffic, last_traffic)
      {
        received: calculate_traffic(new_traffic[:received], last_traffic['received']),
        sent: calculate_traffic(new_traffic[:sent], last_traffic['sent'])
      }
    end

    def dump_stat(wg_stat)
      File.write(WG_STAT_PATH, JSON.pretty_generate(wg_stat))
    end

    def calculate_traffic(new_t, old_t)
      result = new_t.to_unit + old_t.to_unit
      result.convert_to('GiB').round(2).to_s
    end
  end
end
