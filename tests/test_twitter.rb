require 'twitter'

class TC_TwitterOAuth < Test::Unit::TestCase
  def setup
    @test_tweet = Time.now

    parameters = OpenStruct.new(YAML.load_file "#{ROOT}/config.yaml")
    @obj = Twitter::OAuth.new(
      parameters.consumer_key,
      parameters.consumer_secret,
      parameters.access_token,
      parameters.access_token_secret
    )
  end

  #
  # OAuth 認証後の Tweet をテストする
  #
  # 1. Tweet が成功するかどうか
  # 2. 同内容の多重 Tweet が失敗するかどうか
  # 3. 1 で Post した Tweet を削除できるかどうか
  #
  def test_tweet
    response = @obj.post('http://api.twitter.com/1/statuses/update.xml', { :status => @test_tweet })
    assert_equal(response.code.to_i, 200)

    id = response.body[/<id>(.+)<\/id>?/][/\d+/]

    response = @obj.post('http://api.twitter.com/1/statuses/update.json', { :status => @test_tweet })
    assert_equal(response.code.to_i, 403)

    response = @obj.delete("http://api.twitter.com/1/statuses/destroy/#{id}.json")
    assert_equal(response.code.to_i, 200)
  end
end
