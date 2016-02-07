# Forked from lib/anemone/exceptions.rb
# https://github.com/chriskite/anemone/
# Copyright (c) 2009 Vertive, Inc.
# Released under the MIT.
# https://github.com/chriskite/anemone/blob/master/LICENSE.txt

module CafeScraper
  class Error < ::StandardError
    attr_accessor :wrapped_exception
  end
end
