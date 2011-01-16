source 'http://rubygems.org'

gem 'rails', '~> 3.0.3'

gem 'sweetsuite', :path => '../sweetsuite-gem'

gem 'compass'
gem 'haml-rails'
gem 'sqlite3-ruby', :require => 'sqlite3'
gem 'thin'


group :development do
  gem 'heroku'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'ruby-debug19'
  gem 'steak'
end

group :test do
  if RUBY_PLATFORM =~ /darwin/
    gem 'autotest-fsevent'
    gem 'autotest-growl'
    gem 'autotest-rails'
    gem 'ZenTest'
  end

  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'fuubar'
  gem 'launchy'
  gem 'shoulda'
end

