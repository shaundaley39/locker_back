ENV['RACK_ENV'] = 'test'
require_relative '../app'

require 'rspec'
require "capybara"
require "capybara/dsl"
require 'capybara/rspec'
require 'headless'

Capybara.app = Application
Capybara.default_wait_time = 10
Capybara.server_port = 9292

RSpec.configure do |config|
  config.mock_with :rspec
  config.include Capybara::DSL
end

begin
  headless = Headless.new
  headless.start
rescue
end

