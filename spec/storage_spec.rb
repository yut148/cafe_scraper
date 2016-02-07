# Forked from spec/storage_spec.rb
# https://github.com/chriskite/anemone/
# Copyright (c) 2009 Vertive, Inc.
# Released under the MIT.
# https://github.com/chriskite/anemone/blob/master/LICENSE.txt

$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

%w[pstore].each { |file| require "cafe_scraper/storage/#{file}.rb" }

module CafeScraper
  describe Storage do

    describe ".Hash" do
      it "returns a Hash adapter" do
        expect(CafeScraper::Storage.Hash).to be_instance_of(Hash)
      end
    end

    describe ".PStore" do
      it "returns a PStore adapter" do
        test_file = 'test.pstore'
        expect(CafeScraper::Storage.PStore(test_file)).to be_instance_of(CafeScraper::Storage::PStore)
      end
    end

    describe 'Storage' do
      shared_examples_for "storage engine" do

        before(:each) do
          @url = SPEC_DOMAIN
          @page = Page.new(URI(@url))
        end

        it "should implement [] and []=" do
          expect(@store).to respond_to(:[])
          expect(@store).to respond_to(:[]=)

          @store[@url] = @page
          expect(@store[@url].url).to eq URI(@url)
        end

        it "should implement has_key?" do
          expect(@store).to respond_to(:has_key?)

          @store[@url] = @page
          expect(@store.has_key?(@url)).to be true

          expect(@store.has_key?('missing')).to be false
        end

        it "should implement delete" do
          expect(@store).to respond_to(:delete)

          @store[@url] = @page
          expect(@store.delete(@url).url).to eq @page.url
          expect(@store.has_key?(@url)).to be false
        end

        it "should implement keys" do
          expect(@store).to respond_to(:keys)

          urls = [SPEC_DOMAIN, SPEC_DOMAIN + 'test', SPEC_DOMAIN + 'another']
          pages = urls.map { |url| Page.new(URI(url)) }
          urls.zip(pages).each { |arr| @store[arr[0]] = arr[1] }

          expect((@store.keys - urls)).to eq []
        end

        it "should implement each" do
          expect(@store).to respond_to(:each)

          urls = [SPEC_DOMAIN, SPEC_DOMAIN + 'test', SPEC_DOMAIN + 'another']
          pages = urls.map { |url| Page.new(URI(url)) }
          urls.zip(pages).each { |arr| @store[arr[0]] = arr[1] }

          result = {}
          @store.each { |k, v| result[k] = v }
          expect((result.keys - urls)).to eq []
          expect((result.values.map { |page| page.url.to_s } - urls)).to eq []
        end

        it "should implement merge!, and return self" do
          expect(@store).to respond_to(:merge!)

          hash = {SPEC_DOMAIN => Page.new(URI(SPEC_DOMAIN)),
                  SPEC_DOMAIN + 'test' => Page.new(URI(SPEC_DOMAIN + 'test'))}
          merged = @store.merge! hash
          hash.each { |key, value|
            expect(@store[key].url.to_s).to eq key
          }

          expect(merged).to equal @store
        end

        it "should correctly deserialize nil redirect_to when loading" do
          expect(@page.redirect_to).to be_nil
          @store[@url] = @page
          expect(@store[@url].redirect_to).to be_nil
        end
      end

      describe PStore do
        it_should_behave_like "storage engine"

        before(:each) do
          @test_file = 'test.pstore'
          File.delete @test_file rescue nil
          @store =  CafeScraper::Storage.PStore(@test_file)
        end

        after(:all) do
          File.delete @test_file rescue nil
        end
      end

    end
  end
end
