source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.0'

# Bundle for Postgres
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.10'

# Authentication library
gem 'devise'

# Pagination library
gem 'kaminari'

gem 'oauth2'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-linkedin'

gem 'pointpin', '~> 1.0.0'

gem 'recaptcha', :require => 'recaptcha/rails'

gem 'will_paginate', '~> 3.0.5'

gem 'geoip2'
gem 'chartkick'
gem 'geocoder'
gem 'passenger'
gem 'spring'
gem 'pry-rails'
gem 'simple_form'
gem 'countries'
gem 'country_select', '~> 2.0.0.rc'
gem 'paperclip', '~> 4.1'
gem 'jc-validates_timeliness'
gem 'activerecord-session_store'
gem 'color-generator'
gem 'gruff'
gem 'c3-rails', '~> 0.3'
gem 'gmaps4rails'
gem 'underscore-rails'
gem 'twitter-typeahead-rails'
gem 'whenever', require: false
gem 'friendly_id', '~> 5.0.4'

group :production do
  # because capistrano fails otherwise
  # http://stackoverflow.com/questions/21560297/capistrano-sshauthenticationfailed-not-prompting-for-password
  gem 'net-ssh', '2.7.0'
  gem 'rvm-capistrano'
  gem 'capistrano'
  gem 'newrelic_rpm'
  gem 'exception_notification'
  gem 'htmlbeautifier'
end

group :development, :test do
  # gem 'rack-livereload'
  # gem 'guard-livereload'
  gem 'factory_girl_rails', require: false
  gem 'capybara'
  gem 'rspec-rails', '~> 3.0.0'
  gem 'quiet_assets'
  gem 'best_errors'
end

group :test do
  gem 'shoulda'
end
