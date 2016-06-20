require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models/shop.rb'
require 'mechanize'
require 'net/http'
require 'json'


BASE_URL_GOOGLE_MAP = "http://maps.google.com/maps/api/geocode/json"
BASE_URL_YOLP_GEOCODER = "http://geo.search.olp.yahooapis.jp/OpenLocalPlatform/V1/geoCoder"
APP_ID_YAHOO = "dj0zaiZpPVRGeVdKUE1RQUdWRCZzPWNvbnN1bWVyc2VjcmV0Jng9Nzk-"


# スクレイピング
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


# 住所から緯度経度を検出
def geocode_yolp(address)

  address = URI.encode(address)
  hash = Hash.new

  # 出力形式にJSONを指定する
  reqUrl = "#{BASE_URL_YOLP_GEOCODER}?appid=#{APP_ID_YAHOO}&query=#{address}&output=json"
  response = Net::HTTP.get_response(URI.parse(reqUrl))

  # レスポンスコードのチェック
  # 詳細は http://magazine.rubyist.net/?0013-BundledLibraries
  case response
  # 200 OK
  when Net::HTTPSuccess then
    data = JSON.parse(response.body)
    # puts data
    #p status # for DEBUG
    # YOLPでの座標情報は緯度経度に分かれていない（カンマ区切りの）ため分解する
    if data['ResultInfo']['Count']==1
      coordinates = data['Feature'][0]['Geometry']['Coordinates'].split(/,\s?/)
      lat = coordinates[1].to_f # 緯度
      lng = coordinates[0].to_f # 経度
    else
      lat = 0.00
      lng = 0.00
    end
  # それ以外
  else
    lat = 0.00
    lng = 0.00
  end


  return lat,lng

end

latlng = Array.new

for i in 0..n-1 do
    addi = storeAddresses[i]
    latlng = geocode_yolp(addi)
    Shop.create({
        name: storeNames[i],
        address: storeAddresses[i],
        lat: latlng[0],
        lng: latlng[1],
        url: forSps[i],
        category: 'starbucks'
    })
end

puts ('complete')
