# frozen_string_literal: true

source 'https://rubygems.org'

gem 'chunky_png', '~> 1.3', '>= 1.3.5'
gem 'config', '~> 5.5'
gem 'ipaddr', '~> 1.2', '>= 1.2.6'
gem 'json-schema', '~> 4.3'
gem 'puma', '~> 6.4', '>= 6.4.2'
gem 'rake', '~> 13.2', '>= 13.2.1'
gem 'rqrcode', '~> 2.0'
gem 'ruby-units', '~> 4.0', '>= 4.0.3'
gem 'sinatra', '~> 4.0'
gem 'sinatra-contrib', '~> 4.0'

# NOTE: These gems are here and not in dev mode, for access to the console
gem 'byebug', '~> 11.1', '>= 11.1.3'
gem 'pry-byebug', '~> 3.10', '>= 3.10.1'

group :development do
  gem 'dotenv', '~> 3.1', '>= 3.1.2'
  gem 'rack-test', '~> 2.1'
  gem 'rspec', '~> 3.13'
  gem 'rubocop', '~> 1.64'
  gem 'rubocop-rake', '~> 0.6.0'
  gem 'rubocop-rspec', '~> 2.29', '>= 2.29.2'
  gem 'super_diff', '~> 0.12.1'
end

# NOTE: These 2 gems are essentially needed exclusively for debugging in real use.
# The average user does not need them.
# And they start working only if there is a special setting
group :production do
  gem 'sentry-ruby', '~> 5.17', '>= 5.17.3'
  gem 'stackprof', '~> 0.2.26'
end
