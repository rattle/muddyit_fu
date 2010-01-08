#!/usr/bin/ruby

# Script to ease muddy oauth application verification
# from http://github.com/jnunemaker/twitter/blob/master/examples/oauth.rb

require 'rubygems'
require 'muddyit_fu'
require 'launchy'

puts "> enter consumer key"
token = gets.chomp
puts "> enter consumer secret"
secret = gets.chomp

oauth   = Muddyit::OAuth.new(token, secret)
rtoken  = oauth.request_token.token
rsecret = oauth.request_token.secret

puts "> redirecting you to muddy to authorize"
puts "> opening #{oauth.request_token.authorize_url}"
Launchy.open(oauth.request_token.authorize_url)

puts "> authorize in the browser and then press enter"
waiting = gets.chomp

begin
  stoken,ssecret = oauth.authorize_from_request(rtoken, rsecret)

  puts "Access Details"
  puts
  puts "Token : #{stoken}"
  puts "Secret : #{ssecret}"
  puts

  puts "Account collections"
  puts
  
  muddyit =  Muddyit.new(:consumer_key => token,
                         :consumer_secret => secret,
                         :access_token => stoken,
                         :access_token_secret => ssecret)
  
  muddyit.collections.find(:all).each do |collection|
    puts "#{collection.label} has token #{collection.token}"
  end

rescue OAuth::Unauthorized
  puts "> FAIL!"
end
