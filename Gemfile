source 'https://rubygems.org'

gem 'rails', '3.2.13'

# Server gems
gem 'redis', '2.2.2'
gem 'redis-rails'
#gem 'resque'
#gem 'resque-scheduler'

group :production do
  gem 'unicorn'
  gem 'pg'
end

group :development do
  gem 'thin'
  gem 'sqlite3'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'bootstrap-sass'
end

# timezones -- Not needed -- Rails handles everything fine.
#gem 'tzinfo'
#gem 'tzinfo-data'

gem 'jquery-rails'
gem 'rails_admin'
gem 'simple_form'
gem 'devise'
gem 'devise_invitable'
#gem 'public_activity'
gem 'json'

# external services
gem 'newrelic_rpm'
gem 'intercom'
gem 'intercom-rails'
gem 'twilio-ruby'
gem 'sentry-raven'

# spreadsheet parsing, used for importing company/provider appointments
gem 'roo'
