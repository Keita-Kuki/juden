require 'net/http'
require 'json'

BASE_URL_GOOGLE_MAP = "http://maps.google.com/maps/api/geocode/json"
BASE_URL_YOLP_GEOCODER = "http://geo.search.olp.yahooapis.jp/OpenLocalPlatform/V1/geoCoder"
APP_ID_YAHOO = "dj0zaiZpPVRGeVdKUE1RQUdWRCZzPWNvbnN1bWVyc2VjcmV0Jng9Nzk-"


def geocode_google_map(address)

  address = URI.encode(address)
  hash = Hash.new
  reqUrl = "#{BASE_URL_GOOGLE_MAP}?address=#{address}&sensor=false&language=ja"
  response = Net::HTTP.get_response(URI.parse(reqUrl))

  # レスポンスコードのチェック
  # 詳細は http://magazine.rubyist.net/?0013-BundledLibraries
  case response
  # 200 OK
  when Net::HTTPSuccess then
    data = JSON.parse(response.body)
    if data['status']=="OK" then
      lat = data['results'][0]['geometry']['location']['lat']
      lng = data['results'][0]['geometry']['location']['lng']
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
    puts data
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

# coordinates = geocode_yolp("東京都港区芝公園4‐2‐8")
# p coordinates

# puts geocode_google_map("東京都 千代田区 丸の内3-3-1 丸の内新東京ビル")
puts geocode_yolp("東京都港区芝公園4‐2‐8")