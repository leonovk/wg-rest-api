# frozen_string_literal: true

source 'https://rubygems.org'

gem 'chunky_png', '~> 1.3', '>= 1.3.5'
gem 'config', '~> 5.6'
gem 'digest', '~> 3.2'
gem 'faraday', '~> 2.14'
gem 'ipaddr', '~> 1.2'
gem 'json-schema', '~> 6.0'
gem 'puma', '~> 7.0'
gem 'rainbow', '~> 3.1', '>= 3.1.1'
gem 'rake', '~> 13.3'
gem 'rqrcode', '~> 3.1'
gem 'ruby-units', '~> 4.1'
gem 'rubyzip', '~> 3.1'
gem 'simple_monads', '~> 1.0'
gem 'sinatra', '~> 4.2'
gem 'sinatra-contrib', '~> 4.1'

# NOTE: These gems are here and not in dev mode, for access to the console
gem 'byebug', '~> 12.0'
gem 'pry-byebug', '~> 3.10', '>= 3.10.1'

group :development do
  gem 'dotenv', '~> 3.1'
  gem 'rubocop', '~> 1.80'
  gem 'rubocop-rake', '~> 0.7.1'
  gem 'rubocop-rspec', '~> 3.7'
  gem 'super_diff', '~> 0.16.0'
end

group :test do
  gem 'rack-test', '~> 2.2'
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
  gem 'sentry-ruby', '~> 5.28'
  gem 'stackprof', '~> 0.2.27'
end
