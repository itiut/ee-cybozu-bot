require 'twitter'
require_relative 'db/connection'
require_relative 'models/group'
require_relative 'models/notice'
require_relative 'models/tweet_queue'

class Tweeter
  MESSAGE_MAX_CHARS = 105

  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end
  end

  def tweet_queued_notices
    now = Time.new
    TweetQueue.order(:tweet_at).all do |tweet|
      next if now < tweet.tweet_at

      notice = Notice[tweet.notice_id]
      group = Group[notice.group_id]
      message = [notice.title, '（', group.name, '）', notice.content].join.slice(0, MESSAGE_MAX_CHARS)

      DB.transaction do
        update(message + ' ' + notice.url)
        tweet.delete
      end

      sleep 1
    end
  end

  def update(message)
    @client.update(message)
    puts "Tweet: #{message}"
  end
end
