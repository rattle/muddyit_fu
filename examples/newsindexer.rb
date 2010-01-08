#!/usr/bin/ruby
require 'rubygems'
require 'muddyit_fu'
require 'rss'
require 'open-uri'

# Connect to Muddy
muddyit =  Muddyit.new('./config.yml')
collection= muddyit.collections.find(:all).first
# Parse RSS
rss_content = ''
open('http://newsrss.bbc.co.uk/rss/newsonline_uk_edition/uk_politics/rss.xml') do |f|
  rss_content = f.read
end
rss = RSS::Parser.parse(rss_content, false)
# Loop through, analyse and display entities
rss.items.each do |item|
  page = collection.pages.create({:uri => item.guid.content}, {:realtime => true, :store => false})
  puts "#{item.guid.content} contains:"
  page.entities.each do |entity|
    puts "\t#{entity.term}, #{entity.classification}"
  end
end

