# frozen_string_literal: true

source 'https://rubygems.org'

gem 'chunky_png', '~> 1.3', '>= 1.3.5'
gem 'config', '~> 5.5'
gem 'digest', '~> 3.1', '>= 3.1.1'
gem 'faraday', '~> 2.12'
gem 'ipaddr', '~> 1.2', '>= 1.2.6'
gem 'json-schema', '~> 5.0'
gem 'puma', '~> 6.4'
gem 'rainbow', '~> 3.1', '>= 3.1.1'
gem 'rake', '~> 13.2', '>= 13.2.1'
gem 'rqrcode', '~> 2.0'
gem 'ruby-units', '~> 4.1'
gem 'simple_monads', '~> 1.0'
gem 'sinatra', '~> 4.0'
gem 'sinatra-contrib', '~> 4.0'

# NOTE: These gems are here and not in dev mode, for access to the console
gem 'byebug', '~> 11.1', '>= 11.1.3'
gem 'pry-byebug', '~> 3.10', '>= 3.10.1'

group :development do
  gem 'dotenv', '~> 3.1'
  gem 'rubocop', '~> 1.66'
  gem 'rubocop-rake', '~> 0.6.0'
  gem 'rubocop-rspec', '~> 3.0'
  gem 'super_diff', '~> 0.13.0'
end

group :test do
  gem 'rack-test', '~> 2.1'
  gem 'rspec', '~> 3.13'
  gem 'simplecov', require: false
  gem 'timecop', '~> 0.9.10'
  gem 'webmock', '~> 3.24'
end

# NOTE: An extremely platform-dependent gem that is needed only for development.
# So I put it in a separate group.
group :rerun do
  gem 'rerun', '~> 0.14.0'
end

# NOTE: These 2 gems are essentially needed exclusively for debugging in real use.
# The average user does not need them.
# And they start working only if there is a special setting
group :production do
  gem 'sentry-ruby', '~> 5.20'
  gem 'stackprof', '~> 0.2.26'
end
