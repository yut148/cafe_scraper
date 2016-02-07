# Forked from lib/anemone/storage/pstore.rb
# https://github.com/chriskite/anemone/
# Copyright (c) 2009 Vertive, Inc.
# Released under the MIT.
# https://github.com/chriskite/anemone/blob/master/LICENSE.txt

require 'pstore'
require 'forwardable'

module CafeScraper
  module Storage
    class PStore
      extend Forwardable

      def_delegators :@keys, :has_key?, :keys, :size

      def initialize(file)
        File.delete(file) if File.exists?(file)
        @store = ::PStore.new(file)
        @keys = {}
      end

      def [](key)
        @store.transaction { |s| s[key] }
      end

      def []=(key,value)
        @keys[key] = nil
        @store.transaction { |s| s[key] = value }
      end

      def delete(key)
        @keys.delete(key)
        @store.transaction { |s| s.delete key}
      end

      def each
        @keys.each_key do |key|
          value = nil
          @store.transaction { |s| value = s[key] }
          yield key, value
        end
      end

      def merge!(hash)
        @store.transaction do |s|
          hash.each { |key, value| s[key] = value; @keys[key] = nil }
        end
        self
      end

      def close; end

    end
  end
end
