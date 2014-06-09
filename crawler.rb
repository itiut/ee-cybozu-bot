require 'mechanize'
require_relative 'db/connection'
require_relative 'models/notice'
require_relative 'models/tweet_queue'

class Crawler
  BASE_URL = 'https://www.ee.t.u-tokyo.ac.jp/cgi-bin/cb6/ag.cgi'

  def initialize(id, password)
    @id, @password = id, password
    @agent = Mechanize.new
    @agent.user_agent_alias = 'Windows IE 9'
    login!
  end

  def crawl_head_notices
    head_notice_urls.each do |url|
      puts "Crawl: #{url}"
      notice_page = @agent.get(url)
      params = Parser.new(notice_page).parse

      next if Notice[params[:id]]

      create_notice_and_push_to_queue(params)
    end
  end

  private

  def login!
    login_page = @agent.get(BASE_URL)
    login_form = login_page.forms[0]
    login_form._ID = @id
    login_form.Password = @password
    @agent.submit(login_form)
    puts "Login:"
  end

  def head_notice_urls
    bulletin_url = BASE_URL + '?page=BulletinIndex'
    bulletin_page = @agent.get(bulletin_url)
    puts "Crawl: #{bulletin_url}, #{bulletin_page.title}"
    bulletin_page.search('table.dataList//a').map { |anchor| anchor[:href] }
  end

  def create_notice_and_push_to_queue(params)
    DB.transaction do
      notice = Notice.create(params)
      TweetQueue.create(notice_id: notice.id, tweet_at: notice.issued_at)
      puts "Notice: #{notice.id}, #{notice.group_id}, #{notice.title}, #{notice.issued_at}"
    end
  end

  class Parser
    def initialize(notice_page)
      @notice_page = notice_page
    end

    def parse
      id = /&bid=(\d+)/.match(@notice_page.uri.to_s)[1]
      puts "Parse: id=#{id}"
      gid_match = /&gid=(\d+)/.match(@notice_page.uri.to_s)
      group_id = gid_match ? gid_match[1] : 0
      puts "Parse: group_id=#{group_id}"
      title = @notice_page.search('div[@class=marginFull]/table/tr/td/font/b').children.last.text
      puts "Parse: title=#{title}"
      content = @notice_page.search('tt').first.text.split.join.gsub(/[　\s]+/, ' ')
      puts "Parse: content=#{content}"
      p "issued_at"
      p @notice_page.search('body').children[15..25].map { |t| t.text }
      issued_at = Time.parse(@notice_page.search('body').children[20].text.split[1..2].join)
      puts "Parse: issued_at=#{issued_at.to_s}"
      url = @notice_page.uri.to_s
      puts "Parse: url=#{url}"

      { id: id, group_id: group_id, title: title, content: content, issued_at: issued_at, url: url }
    end
  end
end
