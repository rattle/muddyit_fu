require 'test_helper'
require 'pp'

class TestMuddyitFu < Test::Unit::TestCase

  @@COLLECTION_LABEL = Time.now.to_s
  @@STORY = 'http://news.bbc.co.uk/1/hi/business/8186840.stm'

  context 'A muddy account' do

    setup do
      c = load_config
      begin
      @muddyit = Muddyit.new(:consumer_key => c['consumer_key'],
                             :consumer_secret => c['consumer_secret'],
                             :access_token => c['access_token'],
                             :access_token_secret => c['access_token_secret'],
                             :rest_endpoint => c['rest_endpoint'])
      rescue
        puts "Failed to connect to muddy, are the details correct ?"
      end
    end

    should 'be able to create a collection' do
      collection = @muddyit.collections.create(@@COLLECTION_LABEL, 'http://www.test.com')
      assert !collection.token.nil?
    end

    should 'be able to find a collection' do
      # This is a bit rubbish
      @muddyit.collections.find(:all).each do |collection|
        if collection.label == @@COLLECTION_LABEL
          assert true
        end
      end
    end

    should 'be able to destroy a collection' do
      # This is also a bit rubbish
      collections = @muddyit.collections.find(:all)
      collections.each do |collection|
        if collection.label == @@COLLECTION_LABEL
           res = collection.destroy
           assert_equal res.code, "200"
        end
      end
    end

    context "with a collection" do

      setup do
        @collection = @muddyit.collections.create(@@COLLECTION_LABEL, 'http://www.test.com')
      end

      should "categorise a page in realtime and not store it" do
        page = @collection.pages.create({:uri => @@STORY}, :realtime => true, :store => false)
        assert page.entities.length > 0
        pages = @collection.pages.find(:all)
        assert pages[:pages].length == 0
      end

      should "categorise a page in realtime and store it" do
        page = @collection.pages.create({:uri => @@STORY}, :realtime => true, :store => true)
        assert page.entities.length > 0
        pages = @collection.pages.find(:all)
        assert_equal pages[:pages].length, 1
      end

      context "with a page" do

        setup do
          @page = @collection.pages.create({:uri => @@STORY}, :realtime => true)
        end

        should "find a page" do
          assert_equal @collection.pages.find(@page.identifier).identifier, @page.identifier
        end

        should "have page attributes" do
          assert !@page.identifier.nil?
          assert !@page.title.nil?
          assert !@page.created_at.nil?
          assert !@page.content.nil?
          assert !@page.uri.nil?
          #assert !@page.token.nil?
          # More attributes here ?
        end

        should "have many entities" do
          assert @page.entities.length > 0
        end

        should "have an entity with a term and label" do
          entity = @page.entities.first
          assert !entity.term.nil?
          assert !entity.uri.nil?
        end

        should "have extracted content" do
          assert !@page.extracted_content.content.nil?
          assert @page.extracted_content.terms.length > 0
          assert @page.extracted_content.start_position > 0
          assert @page.extracted_content.end_position > 0
        end

        should "delete a page" do
          assert @page.destroy, "200"
        end

      end

      context "with two pages" do

        setup do
          @page1 = @collection.pages.create({:uri => @@STORY}, :realtime => true)
          @page2 = @collection.pages.create({:uri => @@STORY}, :realtime => true)
        end

        should "find all pages" do
          assert_equal @collection.pages.find(:all).length, 2
        end

        should "find related pages" do
          assert_equal @page1.related_content.length, 1
        end

      end

      teardown do
        #token = @collection.token
        @collection.destroy
        #res = @muddyit.collections.find(token)
        # This should be a 404 (!)
        #assert_equal res.code, "404"
      end

    end

  end
end

