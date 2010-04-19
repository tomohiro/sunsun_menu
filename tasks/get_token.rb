#!/usr/bin/env ruby

require 'ostruct'

require 'rubygems'
require 'oauth'

ROOT = File.expand_path('..', File.dirname(__FILE__))

parameters = OpenStruct.new(YAML.load_file "#{ROOT}/config.yaml")
consumer = OAuth::Consumer.new(
  parameters.consumer_key,
  parameters.consumer_secret,
  {:site => 'http://twitter.com', :proxy => ENV['http_proxy']}
)

request_token = consumer.get_request_token

puts "Access this URL and approve => #{request_token.authorize_url}"

print "Input OAuth Verifier: "
oauth_verifier = gets.chomp.strip

access_token = request_token.get_access_token(
  :oauth_verifier => oauth_verifier
)

puts "Access token: #{access_token.token}"
puts "Access token secret: #{access_token.secret}"
