# frozen_string_literal: true

RSpec.describe WireGuard::StatParser do
  subject(:parse) { described_class.new.parse }

  before do
    allow(WireGuard::StatGenerator).to receive_messages(show: wg_show_stub)
  end

  context 'when all data is present' do
    let(:wg_show_stub) { File.read('spec/fixtures/stat.txt') }
    let(:expected_result) do
      {
        'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=' => {
          last_online: '25 seconds ago',
          traffic: {
            received: '56.28 MiB',
            sent: '1.35 GiB'
          }
        },
        'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=' => {
          last_online: '30 seconds ago',
          traffic: {
            received: '199.29 MiB',
            sent: '722.39 MiB'
          }
        },
        'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=' => {
          last_online: '13 seconds ago',
          traffic: {
            received: '62.44 MiB',
            sent: '3.21 GiB'
          }
        }
      }
    end

    it 'returns the expected result' do
      expect(parse).to eq(expected_result)
    end
  end

  context 'when data is not available for all clients' do
    let(:wg_show_stub) { File.read('spec/fixtures/stat_with_empty.txt') }
    let(:expected_result) do
      {
        'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=' => {},
        'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=' => {},
        'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=' => {
          last_online: '13 seconds ago',
          traffic: {
            received: '62.44 MiB',
            sent: '3.21 GiB'
          }
        }
      }
    end

    it 'returns the expected result' do
      expect(parse).to eq(expected_result)
    end
  end
end
