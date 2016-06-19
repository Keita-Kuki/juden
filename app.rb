require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'mechanize'

# 管理者ページ　スクレイピング更新
get '/admin' do
  erb :admin
end

post '/scrape' do
  agent = Mechanize.new
  page = agent.get("http://www.starbucks.co.jp/store/search/result.php?search_type=1&pref_code=13&city=")
  storeName = page.search('//p[@class="storeName"]')
  forSp = page.search('//p[@class="forSp"]')
  storeAddress = page.search('//p[@class="storeAdress"]')
  
  puts forSp
  
  redirect '/'
end

get '/' do
  erb :index
end