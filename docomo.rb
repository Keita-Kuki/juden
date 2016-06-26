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




shoptextinner = Array.new
regioninner = Array.new
locainner = Array.new
stinner = Array.new

shopNames = Array.new
shopRegion = Array.new
shopLocation = Array.new
shopStreet = Array.new
shopAdress = Array.new




# スクレイピング
for i in 1..21 do
  agent = Mechanize.new
  page = agent.get("https://mobilephone.geomedian.com/category/j131#{"%02d" % i}/?scate=docomo")
  shoptextlink = page.search('//a[@class="shoptextlink"]')
  addressRegion = page.search('//span[@itemprop="addressRegion"]')
  addressLocality = page.search('//span[@itemprop="addressLocality"]')
  streetAddress = page.search('//span[@itemprop="streetAddress" ]')
  
  j = 0
  shoptextinner = []
  shoptextlink.each do |shoptext|
    shoptextinner[j] = shoptext.inner_text
    j += 1
  end
  
  j = 0
  regioninner = []
  addressRegion.each do |region|
    regioninner[j] = region.inner_text
    j += 1
  end
  
  j = 0
  locainner = []
  addressLocality.each do |location|
    locainner[j] = location.inner_text
    j += 1
  end
  
  j = 0
  stinner = []
  streetAddress.each do |street|
    stinner[j] = street.inner_text
    j += 1
  end
  
  shopNames.concat(shoptextinner)
  shopRegion.concat(regioninner)
  shopLocation.concat(locainner)
  shopStreet.concat(stinner)
  
end

n = shopNames.length

for i in 0..n-1 do
  shopAdress[i] = shopRegion[i] + shopLocation[i] + shopStreet[i]
end

# puts shopAdress







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
    addi = shopAdress[i]
    latlng = geocode_yolp(addi)
    Shop.create({
        name: shopNames[i],
        address: shopAdress[i],
        lat: latlng[0],
        lng: latlng[1],
        category: 'docomo'
    })
end

puts ('complete')
