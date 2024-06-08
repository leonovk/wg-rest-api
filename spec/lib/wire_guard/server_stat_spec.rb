# frozen_string_literal: true

RSpec.describe WireGuard::ServerStat do
  before do
    allow(WireGuard::StatGenerator).to receive_messages(show: File.read('spec/fixtures/stat.txt'))
  end

  after do
    FileUtils.rm_rf(wg_stat_path)
  end

  let(:wg_stat_path) { "#{Settings.wg_path}/wg0_stat.json" }

  describe '#wg_stat' do
    subject(:wg_stat) { described_class.new.wg_stat }

    let(:expected_result) do
      {
        'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=' => {
          last_online: '25 seconds ago',
          trafik: {
            received: '56.28 MiB',
            sent: '1.35 GiB'
          }
        },
        'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=' => {
          last_online: '30 seconds ago',
          trafik: {
            received: '199.29 MiB',
            sent: '722.39 MiB'
          }
        },
        'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=' => {
          last_online: '13 seconds ago',
          trafik: {
            received: '62.44 MiB',
            sent: '3.21 GiB'
          }
        }
      }
    end

    it 'returns the expected result' do
      expect(wg_stat).to eq(expected_result)
    end
  end

  describe '#show' do
    subject(:show) { described_class.new.show('hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=') }

    let(:expected_result) do
      {
        last_online: '30 seconds ago',
        trafik: {
          received: '199.29 MiB',
          sent: '722.39 MiB'
        }
      }
    end

    it 'returns the expected result' do
      expect(show).to eq(expected_result)
    end
  end
end
