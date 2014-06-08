require 'mechanize'
require 'pry'
require 'pry-byebug'
require 'rb-readline'
require_relative 'db/connection'
require_relative 'models/notice'

agent = Mechanize.new
agent.user_agent_alias = 'Windows IE 9'

login_url = 'https://www.ee.t.u-tokyo.ac.jp/cgi-bin/cb6/ag.cgi'
login_page = agent.get(login_url)

login_form = login_page.forms[0]
login_form._ID = ENV['LOGIN_ID']
login_form.Password = ENV['LOGIN_PASSWORD']

agent.submit(login_form)

bulletin_url = 'ag.cgi?page=BulletinIndex'
bulletin_page = agent.get(bulletin_url)

bulletin_page.search('table.dataList//a').each do |anchor|
  view_page = agent.get(anchor[:href])
  id = /&bid=(\d+)/.match(view_page.uri.to_s)[1]

  unless Notice[id]
    gid_match = /&gid=(\d+)/.match(view_page.uri.to_s)
    group_id = gid_match ? gid_match[1] : 0
    title = view_page.search('div[@class=marginFull]/table/tr/td/font/b').children.last.text
    content = view_page.search('tt').first.text.split.join.gsub(/[　\s]+/, ' ')
    issued_time = Time.parse(view_page.search('body').children[20].text.split[1..2].join)

    notice = Notice.create(
      id: id,
      group_id: group_id,
      title: title,
      content: content,
      issued_time: issued_time
    )

    puts "New notice: #{notice.id}, #{notice.group_id}, #{notice.title}, #{notice.issued_time}"
  end
end
