# frozen_string_literal: true

RSpec.describe Webhooks::Aggregator do
  subject(:events) { described_class.new.events }

  before do
    allow(WireGuard::StatGenerator).to receive_messages(show: wg_show_stub)
    allow(WireGuard::ServerStat).to receive(:new)
  end

  after do
    FileUtils.rm_rf("#{Settings.wg_path}/wg0_events.json")
    FileUtils.rm_rf("#{Settings.wg_path}/wg0_stat.json")
  end

  let(:wg_show_stub) { File.read('spec/fixtures/stat_with_empty.txt') }
end
