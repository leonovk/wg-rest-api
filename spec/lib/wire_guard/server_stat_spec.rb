# frozen_string_literal: true

RSpec.describe WireGuard::ServerStat do
  before do
    allow(WireGuard::StatGenerator).to receive_messages(show: wg_show_stub)
    Timecop.freeze(Date.new(2024, 10, 10))
  end

  after do
    FileUtils.rm_rf(wg_stat_path)
    Timecop.return
  end

  let(:wg_stat_path) { "#{Settings.wg_path}/wg0_stat.json" }
  let(:wg_show_stub) { File.read('spec/fixtures/stat.txt') }

  describe '#wg_stat' do
    subject(:wg_stat) { described_class.new.wg_stat }

    context 'when there is no file with statistics' do
      let(:expected_result) do
        {
          'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=' => {
            last_ip: '109.252.46.192',
            last_online: '2024-10-09 21:49:40 +0000',
            traffic: {
              received: 59_013_857,
              sent: 1_449_551_462
            }
          },
          'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=' => {
            last_ip: '217.66.152.172',
            last_online: '2024-10-09 23:59:30 +0000',
            traffic: {
              received: 208_970_711,
              sent: 757_480_816
            }
          },
          'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=' => {
            last_ip: '212.13.11.203',
            last_online: '2024-10-09 23:58:47 +0000',
            traffic: {
              received: 65_473_085,
              sent: 3_446_711_255
            }
          }
        }
      end

      it 'returns the expected result' do
        expect(wg_stat).to eq(expected_result)
      end

      it 'writes the correct result to a file' do
        wg_stat

        result = File.read(wg_stat_path)

        expect(JSON.parse(result)).to eq(stringify_keys(expected_result))
      end
    end

    context 'when the server already has a file with statistics' do
      before do
        create_conf_file('spec/fixtures/wg0_stat.json', wg_stat_path)
      end

      let(:expected_result) do
        {
          'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=' => {
            last_ip: '109.252.46.192',
            last_online: '2024-10-09 21:49:40 +0000',
            traffic: {
              received: 59_013_857,
              sent: 1_449_551_462
            }
          },
          'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=' => {
            last_ip: '217.66.152.172',
            last_online: '2024-10-09 23:59:30 +0000',
            traffic: {
              received: 208_970_711,
              sent: 757_480_816
            }
          },
          'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=' => {
            last_ip: '212.13.11.203',
            last_online: '2024-10-09 23:58:47 +0000',
            traffic: {
              received: 65_473_085,
              sent: 3_446_711_255
            }
          }
        }
      end

      it 'returns the expected result' do
        expect(wg_stat).to eq(expected_result)
      end

      it 'writes the correct result to a file' do
        wg_stat

        result = File.read(wg_stat_path)

        expect(JSON.parse(result)).to eq(stringify_keys(expected_result))
      end
    end

    context 'when the server generated empty data' do
      let(:wg_show_stub) { File.read('spec/fixtures/stat_with_empty.txt') }

      context 'when there is no file with statistics' do
        let(:expected_result) do
          {
            'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=' => {
              last_ip: '109.252.46.192'
            },
            'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=' => {
              last_ip: '217.66.152.172'
            },
            'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=' => {
              last_ip: '212.13.11.203',
              last_online: '2024-10-09 23:58:47 +0000',
              traffic: {
                received: 65_473_085,
                sent: 3_446_711_255
              }
            }
          }
        end

        it 'returns the expected result' do
          expect(wg_stat).to eq(expected_result)
        end

        it 'writes the correct result to a file' do
          wg_stat

          result = File.read(wg_stat_path)

          expect(JSON.parse(result)).to eq(stringify_keys(expected_result))
        end
      end

      context 'when the server already has a file with statistics' do
        before do
          create_conf_file('spec/fixtures/wg0_stat.json', wg_stat_path)
        end

        let(:expected_result) do
          {
            'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=' => {
              'last_ip' => '109.252.46.192',
              'last_online' => '2024-10-15 19:34:41 +0000',
              'traffic' => {
                'received' => 59_013_857,
                'sent' => 1_449_551_462
              }
            },
            'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=' => {
              'last_ip' => '217.66.152.172',
              'last_online' => '2024-10-15 18:34:41 +0000',
              'traffic' => {
                'received' => 208_970_711,
                'sent' => 757_480_816
              }
            },
            'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=' => {
              last_ip: '212.13.11.203',
              last_online: '2024-10-09 23:58:47 +0000',
              traffic: {
                received: 65_473_085,
                sent: 3_446_711_255
              }
            }
          }
        end

        it 'returns the expected result' do
          expect(wg_stat).to eq(expected_result)
        end

        it 'writes the correct result to a file' do
          wg_stat

          result = File.read(wg_stat_path)

          expect(JSON.parse(result)).to eq(stringify_keys(expected_result))
        end
      end
    end

    context 'when there is a file with empty data on the server' do
      before do
        create_conf_file('spec/fixtures/empty_wg0_stat.json', wg_stat_path)
      end

      context 'when the server returned statistics for all clients' do
        let(:expected_result) do
          {
            'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=' => {
              last_ip: '109.252.46.192',
              last_online: '2024-10-09 21:49:40 +0000',
              traffic: {
                received: 59_013_857,
                sent: 1_449_551_462
              }
            },
            'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=' => {
              last_ip: '217.66.152.172',
              last_online: '2024-10-09 23:59:30 +0000',
              traffic: {
                received: 208_970_711,
                sent: 757_480_816
              }
            },
            'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=' => {
              last_ip: '212.13.11.203',
              last_online: '2024-10-09 23:58:47 +0000',
              traffic: {
                received: 65_473_085,
                sent: 3_446_711_255
              }
            }
          }
        end

        it 'returns the expected result' do
          expect(wg_stat).to eq(expected_result)
        end

        it 'writes the correct result to a file' do
          wg_stat

          result = File.read(wg_stat_path)

          expect(JSON.parse(result)).to eq(stringify_keys(expected_result))
        end
      end

      context 'when the server did not return statistics for all clients' do
        let(:wg_show_stub) { File.read('spec/fixtures/stat_with_empty.txt') }

        let(:expected_result) do
          {
            'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=' => {
              'last_ip' => '137.244.47.77',
              'last_online' => '2024-10-15 19:34:41 +0000',
              'traffic' => {
                'received' => 59_013_857,
                'sent' => 1_449_551_462
              }
            },
            'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=' => {
              last_ip: '217.66.152.172'
            },
            'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=' => {
              last_ip: '212.13.11.203',
              last_online: '2024-10-09 23:58:47 +0000',
              traffic: {
                received: 65_473_085,
                sent: 3_446_711_255
              }
            }
          }
        end

        it 'returns the expected result' do
          expect(wg_stat).to eq(expected_result)
        end

        it 'writes the correct result to a file' do
          wg_stat

          result = File.read(wg_stat_path)

          expect(JSON.parse(result)).to eq(stringify_keys(expected_result))
        end
      end
    end
  end

  describe '#show' do
    subject(:show) { described_class.new.show(peer) }

    context 'when the requested peer is in the statistics' do
      let(:peer) { 'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=' }

      let(:expected_result) do
        {
          last_ip: '217.66.152.172',
          last_online: '2024-10-09 23:59:30 +0000',
          traffic: {
            received: 208_970_711,
            sent: 757_480_816
          }
        }
      end

      it 'returns the expected result' do
        expect(show).to eq(expected_result)
      end
    end

    context 'when the requested peer does not exist' do
      let(:peer) { '123' }

      it 'returns nil' do
        expect(show).to be_nil
      end
    end
  end
end
