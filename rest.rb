require "net/http"
require 'json'

api_key= "58fa4fef-c49a-464e-82be-a30aad009099"
uri = URI("https://api.idolondemand.com/1/api/async/recognizespeech/v1")
#params = { :url => "http://downloads.bbc.co.uk/podcasts/radio4/thought/thought_20150302-1134a.mp3", :language => "en-GB", :apikey => api_key}
#params = { :file => "thought.mp3", :language => "en-GB", :apikey => api_key, :interval => "10"}
#uri.query = URI.encode_www_form(params)

#res = Net::HTTP.post_form(uri, 'file' => "thought.mp3", 'language' => "en-GB", 'apikey' => api_key, 'interval' => "10")
res = Net::HTTP.post_form(uri, 'reference' => "a3e0121e-cc8a-4d3b-9f52-0b012518ecdc", 'language' => "en-GB", 'apikey' => api_key, 'interval' => "10")

#res = Net::HTTP.get_response(uri)
obj = JSON.parse(res.body)

# puts res.body if res.is_a?(Net::HTTPSuccess)
puts obj['jobID']

uri = URI("https://api.idolondemand.com/1/job/status/" + obj['jobID'])
params = {:apikey => api_key}
uri.query = URI.encode_www_form(params)

res = Net::HTTP.get_response(uri)
obj = JSON.parse(res.body)

while obj['status'] == 'queued' do 
   res = Net::HTTP.get_response(uri)
   obj = JSON.parse(res.body)
  sleep(5)
end

uri = URI("https://api.idolondemand.com/1/job/result/" + obj['jobID'])
params = {:apikey => api_key}
uri.query = URI.encode_www_form(params)

res = Net::HTTP.get_response(uri)
puts res.body

