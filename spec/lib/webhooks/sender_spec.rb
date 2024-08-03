# frozen_string_literal: true

RSpec.describe Webhooks::Sender do
  subject(:send) { described_class.new(events).send_events }

  let(:url) { Settings.webhooks_url }
  let(:events) do
    [
      nil,
      { peer: 'f6e12b5b-ea10-47fb-9bcf-c73b2028dfb7', event: 'connected' },
      { peer: 'b954a686-5f45-4ffe-8793-900073d2a580', event: 'disconnected' },
      { peer: '2d675243-502f-46c9-8544-255e0f90576b', event: 'disconnected' },
      { peer: '455a9a69-d70b-4e4f-85e3-8c20516db0e8', event: 'connected' },
      { peer: 'afa4cebf-4991-4752-9925-95b61ee92513', event: 'disconnected' },
      { peer: 'f14b5e34-8f45-4adb-8128-00b74f63b693', event: 'connected' },
      { peer: '5c0fe354-40b8-4b86-b004-15e9a47cec1c', event: 'disconnected' },
      { peer: '15f4c68f-9cd0-4693-afd3-fa936e656f42', event: 'disconnected' },
      { peer: '003c6f7d-f575-4884-9fe1-6a95350fdb05', event: 'connected' },
      { peer: 'ea5d7970-7bd3-45fb-93f9-2f840aeedda0', event: 'disconnected' },
      { peer: '7a921f1e-4924-407c-8345-2f4fbf7945ae', event: 'connected' }
    ]
  end

  before do
    events[1..].each do |event|
      stub_request(:post, url).with(body: event.to_json).to_return(status: 200, body: '{}')
    end

    send
  end

  it 'sends the correct number of events' do
    expect(WebMock).to have_requested(:post, url).times(events.size - 1)
  end

  it 'sends all events' do
    events[1..].each do |event|
      expect(WebMock).to have_requested(:post, url).with(body: event.to_json)
    end
  end
end
