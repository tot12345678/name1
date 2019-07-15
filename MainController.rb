# frozen_string_literal: true

require 'csv'
require 'curb'
require 'nokogiri'

# 'https://www.petsonic.com/hobbit-half/'
puts "Enter url"
url = gets.chomp
puts 'Enter name of file'
file = gets.chomp

def getListOfGoods(link)
  Nokogiri::HTML(Curl.get(link).body)
          .css('div.pro_first_box a')
rescue Curl::Err::MalformedURLError
  # ignored
rescue ArgumentError
  # ignored
end

def pageFider(link)
  Nokogiri::HTML(Curl.get(link).body).css('link[rel="next"]')
end

def getImg(link)
  Nokogiri::HTML(Curl.get(link['href']).body)
          .css('img[class="replace-2x img-responsive"]')
end

def getMass(link)
  Nokogiri::HTML(Curl.get(link['href']).body)
          .css('div.attribute_list span')
          .css('span.radio_label')
end

def getName(link)
  Nokogiri::HTML(Curl.get(link['href']).body)
          .css('h1.product_main_name').text # name
end

def getPrice(link)
  Nokogiri::HTML(Curl.get(link['href']).body)
          .css('div.attribute_list span')
          .css('span.price_comb')
end

def putInFile(img, mass, name, price, csv)
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
    list = getListOfGoods(url)
    if list.nil?
      break
    else
      list.each do |element|
        name = getName(element)
        puts "Scanning... |#{name}"
        mass = getMass(element)
        price = getPrice(element)
        img = getImg(element)
        putInFile(img, mass, name, price, csv)
      end
      if !pageFider(url)[0].nil?
        url = pageFider(url)[0]['href']
      else
        break
      end
    end
    break if url.nil?
  end
end
puts "The work was finished!!! Check #{file} file"
