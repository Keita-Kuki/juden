require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models/shop.rb'
require 'mechanize'

# agent = Mechanize.new
# page = agent.get("http://www.starbucks.co.jp/store/search/result.php?search_type=1&pref_code=13&city=")
# elements = page.search('//p[@class="storeName"]')

    agent = Mechanize.new
    page = agent.get("http://www.starbucks.co.jp/store/search/result.php?search_type=1&pref_code=13&city=")
    storeName = page.search('//p[@class="storeName"]')
    forSp = page.search('//a[@class="forSp"]')
    storeAddress = page.search('//p[@class="storeAddress"]')
    
    n = storeName.length

    i = 0
    storeNames = Array.new
    forSps = Array.new
    storeAddresses = Array.new
    
    
    storeName.each do |name|
    storeNames[i] = name.inner_text
    i += 1
    end
    
    i = 0
    forSp.each do |forS|
    forSps[i] = forS.get_attribute(:href)
    i += 1
    end
    
    i = 0
    storeAddress.each do |address|
    storeAddresses[i] = address.inner_text
    i += 1
    end
    
    for i in 0..n-1 do
    Shop.create({
        name: storeNames[i],
        address: storeAddresses[i],
        url: forSps[i],
        category: 'starbucks'
    })
    end
    
    puts ('complete')

# puts elements