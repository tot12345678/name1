# frozen_string_literal: true

require 'csv'
require 'curb'
require 'nokogiri'

# 'https://www.petsonic.com/hobbit-half/'
puts 'Enter url'
url = gets.chomp
puts 'Enter name of file'
file = gets.chomp

# pars site
class Cast
  def initialize(url_f, attr)
    @link = url_f
    @attr_reader = attr
  end

  def getinfo
    Nokogiri::HTML(Curl.get(@link).body)
            .css(@attr_reader)
  # 'div.pro_first_box a'
  rescue Curl::Err::MalformedURLError
    # ignored
  rescue ArgumentError
    # ignored
  end
end
def put_in_File(img, mass, name, price, csv)
  (0...mass.length).each do |i|
    csv << [format('%-73s %-16s | %9s| %s',
                   name,
                   mass[i].text,
                   price[i].text,
                   if img[i].nil?
                     img[0]['src']
                   else
                     img[i]['src']
                   end)]
  end
end

CSV.open("#{file}.csv", 'wb') do |csv|
  csv << [format('%-73s %-16s | %-9s| %s', ' name', 'mass', ' price', 'img')]
  loop do
    list = Cast.new(url, 'div.pro_first_box a').getinfo
    puts "I fined page #{url} and will scan it \n Please be patient"
    list.each do |element|
      for_parse = element['href']
      put_in_File(Cast.new(for_parse, 'img[class="replace-2x img-responsive"]').getinfo,
            Cast.new(for_parse, 'span.radio_label').getinfo,
            Cast.new(for_parse, 'h1.product_main_name').getinfo.text,
            Cast.new(for_parse, 'span.price_comb').getinfo,
            csv)
    end
    if !Cast.new(url, 'link[rel="next"]').getinfo[0].nil?
      url = Cast.new(url, 'link[rel="next"]').getinfo[0]['href']
    else
      break
    end
  end
  break if url.nil?
end
puts "The work was finished!!! Check #{file} file"
