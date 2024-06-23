# frozen_string_literal: true

RSpec.describe WireGuard::ServerStat do
  before do
    allow(WireGuard::StatGenerator).to receive_messages(show: wg_show_stub)
  end

  after do
    FileUtils.rm_rf(wg_stat_path)
  end

  let(:wg_stat_path) { "#{Settings.wg_path}/wg0_stat.json" }
  let(:wg_show_stub) { File.read('spec/fixtures/stat.txt') }

  describe '#wg_stat' do
    subject(:wg_stat) { described_class.new.wg_stat }

    context 'when there is no file with statistics' do
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
            last_online: '25 seconds ago',
            traffic: {
              received: '0.11 GiB',
              sent: '2.7 GiB'
            }
          },
          'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=' => {
            last_online: '30 seconds ago',
            traffic: {
              received: '0.39 GiB',
              sent: '1.41 GiB'
            }
          },
          'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=' => {
            last_online: '13 seconds ago',
            traffic: {
              received: '0.12 GiB',
              sent: '6.42 GiB'
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

        # NOTE: Look here:
        # lib/wire_guard/server_stat.rb:48
        let(:expected_result) do
          {
            'LiXk4UOfnScgf4UnkcYNcz4wWeqTOW1UrHKRVhZ1OXg=' => {
              'last_online' => '45 seconds ago',
              'traffic' => {
                'received' => '56.28 MiB',
                'sent' => '1.35 GiB'
              }
            },
            'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=' => {
              'last_online' => '50 seconds ago',
              'traffic' => {
                'received' => '199.29 MiB',
                'sent' => '722.39 MiB'
              }
            },
            'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=' => {
              last_online: '13 seconds ago',
              traffic: {
                received: '0.12 GiB',
                sent: '6.42 GiB'
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
              last_online: '25 seconds ago',
              traffic: {
                received: '0.11 GiB',
                sent: '2.7 GiB'
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
                received: '0.12 GiB',
                sent: '6.42 GiB'
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
              'last_online' => '45 seconds ago',
              'traffic' => {
                'received' => '56.28 MiB',
                'sent' => '1.35 GiB'
              }
            },
            'hvIyIW2o8JROVKuY2yYFdUn0oA+43aLuT8KCy0YbORE=' => {},
            'bPKBg66uC1J2hlkE31Of5wnkg+IjowVXgoLcjcLn0js=' => {
              last_online: '13 seconds ago',
              traffic: {
                received: '0.12 GiB',
                sent: '6.42 GiB'
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
          last_online: '30 seconds ago',
          traffic: {
            received: '199.29 MiB',
            sent: '722.39 MiB'
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
