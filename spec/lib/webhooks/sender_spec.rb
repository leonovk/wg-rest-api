# frozen_string_literal: true

RSpec.describe Webhooks::Sender do
  subject(:send) { described_class.new(events).send_events }
end
