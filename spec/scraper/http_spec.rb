# Forked from spec/http_spec.rb
# https://github.com/chriskite/anemone/
# Copyright (c) 2009 Vertive, Inc.
# Released under the MIT.
# https://github.com/chriskite/anemone/blob/master/LICENSE.txt

require 'spec_helper'

module CafeScraper
  module Scraper
    describe HTTP do
      describe "fetch_page" do
        before(:each) do
          FakeWeb.clean_registry
        end

        it "should still return a Page if an exception occurs during the HTTP connection" do
          allow(HTTP).to receive(:refresh_connection).and_raise(StandardError)
          http = CafeScraper::Scraper::HTTP.new
          expect(http.fetch_page(SPEC_DOMAIN)).to be_instance_of(Page)
        end

      end
    end
  end
end
