# frozen_string_literal: true

require_relative 'config'

threads_count = ENV.fetch('PUMA_THREADS', 5).to_i

threads threads_count, threads_count

environment ENV.fetch('ENVIRONMENT', 'development')

port ENV.fetch('PORT', 3000)

workers ENV.fetch('WORKERS', 1).to_i

log_requests

DATETIME_FORMAT = '%Y-%m-%d %H:%M:%S %z'

log_formatter do |str|
  "#{Time.now.strftime DATETIME_FORMAT} : |Puma| #{str}"
end
