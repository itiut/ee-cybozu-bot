require 'clockwork'
require_relative 'crawler'
require_relative 'tweeter'

module Clockwork
  handler do |job|
    job.call
  end

  crawler_job = lambda do
    puts 'Start: crawler_job'
    Crawler.new(ENV['LOGIN_ID'], ENV['LOGIN_PASSWORD']).crawl_head_notices
    puts 'End: crawler_job'
  end

  tweeter_job = lambda do
    puts 'Start: tweeter_job'
    Tweeter.new.tweet_queued_notices
    puts 'End: tweeter_job'
  end

  every(1.hour, crawler_job)
  # every(1.hour, tweeter_job)
end
