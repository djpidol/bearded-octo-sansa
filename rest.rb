require "net/http"

http = Net::HTTP.new("https://api.idolondemand.com")
request = Net::HTTP::Get.new("/1/api/sync/recognizespeech/v1")

request.set_form_data({"v1[url]" => "http%3A%2F%2Fdownloads.bbc.co.uk%2Fpodcasts%2Fradio4%2Fthought%2Fthought_20150302-1134a.mp3"})
request.set_form_data({"v1[language]" => "en-GB"})
request.set_form_data({"v1[apikey]" => "3e25f657-9700-4e26-99ee-4c2544536e7a"})

response = http.request(request)

print request