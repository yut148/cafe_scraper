$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'fakeweb'
require File.dirname(__FILE__) + '/fakeweb_helper'

require 'cafe_scraper'
SPEC_DOMAIN = 'http://www.example.com/'

RSpec.configure do |config|
  config.example_status_persistence_file_path = "./spec/status.txt"
end
