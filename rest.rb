require "net/http"
require 'json'

uri = URI("https://api.idolondemand.com/1/api/async/recognizespeech/v1")
params = { :url => "http://downloads.bbc.co.uk/podcasts/radio4/thought/thought_20150302-1134a.mp3", :language => "en-GB", :apikey => "3e25f657-9700-4e26-99ee-4c2544536e7a"}
uri.query = URI.encode_www_form(params)

res = Net::HTTP.get_response(uri)
obj = JSON.parse(res.body)

# puts res.body if res.is_a?(Net::HTTPSuccess)
puts obj['jobID']

uri = URI("https://api.idolondemand.com/1/job/status/" + obj['jobID'])
params = {:apikey => "3e25f657-9700-4e26-99ee-4c2544536e7a"}
uri.query = URI.encode_www_form(params)

res = Net::HTTP.get_response(uri)
obj = JSON.parse(res.body)

while obj['status'] == 'queued' do 
   res = Net::HTTP.get_response(uri)
   obj = JSON.parse(res.body)
  sleep(5)
end

uri = URI("https://api.idolondemand.com/1/job/results/" + obj['jobID'])
params = {:apikey => "3e25f657-9700-4e26-99ee-4c2544536e7a"}
uri.query = URI.encode_www_form(params)

res = Net::HTTP.get_response(uri)
puts res.body

