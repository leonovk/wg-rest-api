# frozen_string_literal: true

module WireGuard
  # Class for obtaining statistics on traffic and last online clients
  class ServerStat
    def initialize
      @rep = WireGuard::Repository.new
      @last_stat_data = rep.client_stats
      @new_stat_data = StatParser.new.parse
      aggregate_data
    end

    def show(peer)
      client_stat = rep.find_client_stat_by_public_key(peer)
      return {} if client_stat.nil?

      client_stat
    end

    private

    attr_reader :last_stat_data, :new_stat_data, :last_peer, :rep

    def aggregate_data # rubocop:disable Metrics/AbcSize
      new_stat_data.each do |peer, new_data|
        last_data = last_stat_data.find { |data| data[:public_key] == peer }

        next unless (last_data.nil? || last_data.empty?) || !new_data.empty?

        rep.update_client_stat_by_public_key(peer, {
                                               last_online: new_data[:last_online],
                                               received: new_data[:traffic][:received],
                                               sent: new_data[:traffic][:sent]
                                             })
      end
    end
  end
end
