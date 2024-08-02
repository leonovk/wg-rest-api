# frozen_string_literal: true

RSpec.describe Webhooks::Aggregator do
  subject(:events) { described_class.new.events }

  before do
    allow(WireGuard::StatGenerator).to receive_messages(show: wg_show_stub)
    allow(WireGuard::ServerStat).to receive(:new)
    create_conf_file('spec/fixtures/wg0_stat.json', wg_stat_path)
    create_conf_file('spec/fixtures/wg0_events.json', wg_events_path)
  end

  after do
    FileUtils.rm_rf("#{Settings.wg_path}/wg0_events.json")
    FileUtils.rm_rf("#{Settings.wg_path}/wg0_stat.json")
  end

  let(:wg_show_stub) { File.read('spec/fixtures/stat_with_empty.txt') }
  let(:wg_stat_path) { "#{Settings.wg_path}/wg0_stat.json" }
  let(:wg_events_path) { "#{Settings.wg_path}/wg0_events.json" }

  it 'returns correct events' do
    expect(events).to eq([{ peer: 'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=', event: 'disconnected' }])
  end
end
