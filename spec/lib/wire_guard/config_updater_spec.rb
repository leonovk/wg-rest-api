# frozen_string_literal: true

RSpec.describe WireGuard::ConfigUpdater do
  subject(:update) { described_class.update }

  before do
    allow(Kernel).to receive(:system).with('wg-quick down wg0').and_return(true)
    allow(Kernel).to receive(:system).with('wg-quick up wg0').and_return(true)
    create_conf_file('spec/fixtures/wg0.json')

    update
  end

  after do
    FileUtils.rm_rf("#{Settings.wg_path}/wg0.json")
    FileUtils.rm_rf("#{Settings.wg_path}/wg0.conf")
  end

  it 'creates the correct config file for the wireguard server' do
    config = File.read("#{Settings.wg_path}/wg0.conf")

    expect(config).to eq(File.read('spec/fixtures/wg0.conf'))
  end

  it 'restarts the wireguard server' do
    expect(Kernel).to have_received(:system).with('wg-quick up wg0')
  end
end
