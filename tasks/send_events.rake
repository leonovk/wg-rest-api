# frozen_string_literal: true

desc 'send webhooks events'
task :send_events do
  events = Webhooks::Aggregator.new.events
  Webhooks::Sender.new(events).send_events
end
