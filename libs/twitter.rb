ROOT = File.expand_path('..', File.dirname(__FILE__))

require 'yaml'
require 'ostruct'

require 'simple_oauth'

module Twitter
  class OAuth < SimpleOAuth
    def initialize(*args)
      super(*args)
      @proxy = ENV['http_proxy'] || nil
    end

    def request(*args)
      return proxy_request(*args) unless @proxy == nil

      super(*args)
    end

    def proxy_request(method, url, body = nil, headers = {})
      proxy_host = URI.parse(@proxy).host
      proxy_port = URI.parse(@proxy).port

      method = method.to_s
      url = URI.parse(url)
      request = create_http_request(method, url.request_uri, body, headers)
      request['Authorization'] = auth_header(method, url, request.body)
      Net::HTTP.Proxy(proxy_host, proxy_port).new(url.host, url.port).request(request)
    end

    def statuses_update(status)
      response = post('http://api.twitter.com/1/statuses/update.json', { :status => status })
      raise "Request failed: #{response.code}" unless response.code.to_i == 200
    end
  end

  class Bot
    def initialize
      @parameters = OpenStruct.new(YAML.load_file "#{ROOT}/config.yaml")
      @twitter = Twitter::OAuth.new(
        @parameters.consumer_key,
        @parameters.consumer_secret,
        @parameters.access_token,
        @parameters.access_token_secret
      )
    end

    def post(tweets)
      begin
        tweets.each do |tweet|
          @twitter.statuses_update(tweet)
          sleep 5
        end
      rescue => e
        puts "Tweets post failed. (Error => #{e.to_s})"
      end
    end
  end
end
