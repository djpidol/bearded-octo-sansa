require "net/http"
require 'json'

uri = URI("https://api.idolondemand.com/1/api/async/storeobject/v1")
#res = Net::HTTP.post_form(uri, 'file' => "thought.mp3", 'apikey' => "3e25f657-9700-4e26-99ee-4c2544536e7a")
res = Net::HTTP.post_form(uri, 'url' => "http://downloads.bbc.co.uk/podcasts/radio4/thought/thought_20150302-1134a.mp3", 'apikey' => "3e25f657-9700-4e26-99ee-4c2544536e7a")
puts res.body