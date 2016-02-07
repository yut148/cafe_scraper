# Forked from lib/anemone/storage/exceptions.rb
# https://github.com/chriskite/anemone/
# Copyright (c) 2009 Vertive, Inc.
# Released under the MIT.
# https://github.com/chriskite/anemone/blob/master/LICENSE.txt

module CafeScraper
  module Storage

    class GenericError < Error; end;

    class ConnectionError < Error; end

    class RetrievalError < Error; end

    class InsertionError < Error; end

    class CloseError < Error; end

  end
end
