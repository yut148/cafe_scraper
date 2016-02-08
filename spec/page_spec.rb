# Forked from spec/page_spec.rb
# https://github.com/chriskite/anemone/
# Copyright (c) 2009 Vertive, Inc.
# Released under the MIT.
# https://github.com/chriskite/anemone/blob/master/LICENSE.txt

$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

module CafeScraper
  describe Page do

    before(:each) do
      FakeWeb.clean_registry
      @http = CafeScraper::Downloader::HTTP.new
      @page = @http.fetch_page(FakePage.new('home', :links => '1').url)
    end

    it "should indicate whether it successfully fetched via HTTP" do
      expect(@page).to respond_to(:fetched?)
      expect(@page.fetched?).to be true

      fail_page = @http.fetch_page(SPEC_DOMAIN + 'fail')
      expect(fail_page.fetched?).to be false
    end

    it "should store and expose the response body of the HTTP request" do
      body = 'test'
      page = @http.fetch_page(FakePage.new('body_test', {:body => body}).url)
      expect(page.body).to eq body
    end

    it "should record any error that occurs during fetch_page" do
      expect(@page).to respond_to(:error)
      expect(@page.error).to be_nil

      fail_page = @http.fetch_page(SPEC_DOMAIN + 'fail')
      expect(fail_page.error).not_to be_nil
    end

    it "should store the response headers when fetching a page" do
      expect(@page.headers).not_to be_nil
      expect(@page.headers).to have_key('content-type')
    end

    it "should have an OpenStruct attribute for the developer to store data in" do
      expect(@page.data).not_to be_nil
      expect(@page.data).to be_instance_of(OpenStruct)

      @page.data.test = 'test'
      expect(@page.data.test).to eq 'test'
    end

    it "should have a Nokogori::HTML::Document attribute for the page body" do
      expect(@page.doc).not_to be_nil
      expect(@page.doc).to be_instance_of(Nokogiri::HTML::Document)
    end

    it "should indicate whether it was fetched after an HTTP redirect" do
      expect(@page).to respond_to(:redirect?)

      expect(@page.redirect?).to be false

      expect(@http.fetch_pages(FakePage.new('redir', :redirect => 'home').url).first.redirect?).to be true
    end

    it "should have a method to tell if a URI is in the same domain as the page" do
      expect(@page).to respond_to(:in_domain?)

      expect(@page.in_domain?(URI(FakePage.new('test').url))).to be true
      expect(@page.in_domain?(URI('http://www.other.com/'))).to be false
    end

    it "should include the response time for the HTTP request" do
      expect(@page).to respond_to(:response_time)
    end

    it "should have the cookies received with the page" do
      expect(@page).to respond_to(:cookies)
      expect(@page.cookies).to eq []
    end

    describe "#to_hash" do
      it "converts the page to a hash" do
        hash = @page.to_hash
        expect(hash['url']).to eq @page.url.to_s
        expect(hash['referer']).to eq @page.referer.to_s
      end

      context "when redirect_to is nil" do
        it "sets 'redirect_to' to nil in the hash" do
          expect(@page.redirect_to).to be_nil
          expect(@page.to_hash[:redirect_to]).to be_nil
        end
      end

      context "when redirect_to is a non-nil URI" do
        it "sets 'redirect_to' to the URI string" do
          new_page = Page.new(URI(SPEC_DOMAIN), {:redirect_to => URI(SPEC_DOMAIN + '1')})
          expect(new_page.redirect_to.to_s).to eq SPEC_DOMAIN + '1'
          expect(new_page.to_hash['redirect_to']).to eq SPEC_DOMAIN + '1'
        end
      end
    end

    describe "#from_hash" do
      it "converts from a hash to a Page" do
        page = @page.dup
        page.depth = 1
        converted = Page.from_hash(page.to_hash)
        expect(converted.depth).to eq page.depth
      end

      it 'handles a from_hash with a nil redirect_to' do
        page_hash = @page.to_hash
        page_hash['redirect_to'] = nil
        expect{Page.from_hash(page_hash)}.not_to raise_error
        expect(Page.from_hash(page_hash).redirect_to).to be_nil
      end
    end

    describe "#redirect_to" do
      context "when the page was a redirect" do
        it "returns a URI of the page it redirects to" do
          new_page = Page.new(URI(SPEC_DOMAIN), {:redirect_to => URI(SPEC_DOMAIN + '1')})
          redirect = new_page.redirect_to
          expect(redirect).to be_a(URI)
          expect(redirect.to_s).to eq SPEC_DOMAIN + '1'
        end
      end
    end

    it "should detect, store and expose the base url for the page head" do
      base = "#{SPEC_DOMAIN}path/to/base_url/"
      page = @http.fetch_page(FakePage.new('body_test', {:base => base}).url)
      expect(page.base).to eq URI(base)
      expect(@page.base).to be_nil
    end

    it "should have a method to convert a relative url to an absolute one" do
      expect(@page).to respond_to(:to_absolute)

      # Identity
      expect(@page.to_absolute(@page.url)).to eq @page.url
      expect(@page.to_absolute("")).to eq @page.url

      # Root-ness
      expect(@page.to_absolute("/")).to eq URI("#{SPEC_DOMAIN}")

      # Relativeness
      relative_path = "a/relative/path"
      expect(@page.to_absolute(relative_path)).to eq URI("#{SPEC_DOMAIN}#{relative_path}")

      deep_page = @http.fetch_page(FakePage.new('home/deep', :links => '1').url)
      upward_relative_path = "../a/relative/path"
      expect(deep_page.to_absolute(upward_relative_path)).to eq URI("#{SPEC_DOMAIN}#{relative_path}")

      # The base URL case
      base_path = "path/to/base_url/"
      base = "#{SPEC_DOMAIN}#{base_path}"
      page = @http.fetch_page(FakePage.new('home', {:base => base}).url)

      # Identity
      expect(page.to_absolute(page.url)).to eq page.url
      # It should revert to the base url
      expect(page.to_absolute("")).not_to eq page.url

      # Root-ness
      expect(page.to_absolute("/")).to eq URI("#{SPEC_DOMAIN}")

      # Relativeness
      relative_path = "a/relative/path"
      expect(page.to_absolute(relative_path)).to eq URI("#{base}#{relative_path}")

      upward_relative_path = "../a/relative/path"
      upward_base = "#{SPEC_DOMAIN}path/to/"
      expect(page.to_absolute(upward_relative_path)).to eq URI("#{upward_base}#{relative_path}")
    end

  end
end
