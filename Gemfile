source 'http://rubygems.org'

ruby '2.3.0'

gem 'rails', '3.2.22.2'
gem 'test-unit', '~> 3.0'
gem 'nokogiri'
gem 'haml'
gem 'closure-compiler'
gem 'ngannotate-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'bootstrap-sass', '~> 3.2.0'
gem 'sass-rails', '>= 3.2'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :test do
  gem 'sqlite3'
end
group :development, :production do
  gem 'pg'
end
group :production do
  gem 'rails_12factor'
end
#gem 'typhoeus'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
group :development do
  # on ubuntu, this was erroring
  # gem 'ruby-debug19', :require => 'ruby-debug'
end

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
