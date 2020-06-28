require 'open-uri'
require 'nokogiri'

url = 'http://byeopssi.kr/'
doc = Nokogiri::HTML(URI.open("http://byeopssi.kr/sub.asp?mcd=family_story_open"))
titles = doc.xpath('//table/tbody/tr').map do |row|
  title = row.xpath("td[@class=\"subject\"]/a/div").children[2]
  next unless title

  title = title&.text&.strip

  author = row.xpath("td[@class=\"writer\"]/a/div").text

  post_link = row.xpath("td[@class=\"subject\"]/a")[0].attributes['href'].value

  link = url + post_link
  [title, author, link]
end

puts titles