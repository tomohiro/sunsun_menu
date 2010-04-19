#!/usr/bin/env ruby

Dir.chdir(File.expand_path(File.dirname(__FILE__)))

$: << 'libs'

require 'yaml'
require 'ostruct'
require 'rss'
require 'rubygems'
require 'mechanize'
require 'nokogiri'

require 'twitter'

class SunSunMenu < Twitter::Bot

  def initialize
    super

    @agent = login
  end

  def self.hago!
    new.main
  end

  def main
    post get_menu
  end

  def login
    begin
      agent = Mechanize.new

      agent.get(@parameters.openpne_uri) do |login_page|
        login_page.form_with(:name => 'login') do |f|
          f.username = @parameters.username
          f.password = @parameters.password
        end.submit
      end
      agent
    rescue Exception
      raise 'login faild'
    end
  end

  def get_menu
    begin
      menu  = '／(^o^)＼ わかにゃいっ'

      community = @agent.get "#{@parameters.openpne_uri}/?m=pc&a=page_c_topic_detail&target_c_commu_topic_id=298"
      comments  = Nokogiri::HTML(community.body)/'p.text'

      comments.each do |comment|
        lunches = comment.text.split("\n").delete_if { |m| m =~ /^(#|＃)/ }
        date = lunches.shift
        if date =~ Regexp.new("#{Date.today.month}/#{Date.today.day}")
          menu = "#{date} |  #{lunches.join(' or ')} だよ♪  どれにする？"
        end
      end
      menu
    rescue Exception
      '／(^o^)＼ わかにゃいっ'
    end
  end
end

if __FILE__ == $0
  SunSunMenu.hago!
end
