# frozen_string_literal: true

RSpec.describe WireGuard::StatParser do
  subject(:parse) { described_class.new.parse }

  before do
    allow(WireGuard::StatGenerator).to receive_messages(show: wg_show_stub)
    Timecop.freeze(Date.new(2024, 10, 10))
  end

  after { Timecop.return }

  context 'when all data is present' do
    let(:wg_show_stub) { File.read('spec/fixtures/stat.txt') }
    let(:expected_result) do
      {
        'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=' => {
          last_ip: '137.244.47.77',
          last_online: '2024-10-09 21:49:40 +0000',
          traffic: {
            received: 59_013_857,
            sent: 1_449_551_462
          }
        },
        'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=' => {
          last_ip: '137.244.47.78',
          last_online: '2024-10-09 23:59:30 +0000',
          traffic: {
            received: 208_970_711,
            sent: 757_480_816
          }
        },
        'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=' => {
          last_ip: '137.244.47.79',
          last_online: '2024-10-09 23:58:47 +0000',
          traffic: {
            received: 65_473_085,
            sent: 3_446_711_255
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
          last_ip: '137.244.47.79',
          last_online: '2024-10-09 23:58:47 +0000',
          traffic: {
            received: 65_473_085,
            sent: 3_446_711_255
          }
        }
      }
    end

    it 'returns the expected result' do
      expect(parse).to eq(expected_result)
    end
  end
end
