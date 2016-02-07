# Forked from lib/anemone/storage.rb
# https://github.com/chriskite/anemone/
# Copyright (c) 2009 Vertive, Inc.
# Released under the MIT.
# https://github.com/chriskite/anemone/blob/master/LICENSE.txt
require "cafe_scraper/storage/base"

module CafeScraper
  module Storage

    def self.Hash(*args)
      hash = Hash.new(*args)
      # add close method for compatibility with Storage::Base
      class << hash; def close; end; end
      hash
    end

    def self.PStore(*args)
      require 'cafe_scraper/storage/pstore'
      self::PStore.new(*args)
    end

  end
end
