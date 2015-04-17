require "net/http"
require 'json'

uri = URI("https://api.idolondemand.com/1/api/async/storeobject/v1")
#res = Net::HTTP.post_form(uri, 'file' => "thought.mp3", 'apikey' => "58fa4fef-c49a-464e-82be-a30aad009099")
res = Net::HTTP.post_form(uri, 'url' => "http://downloads.bbc.co.uk/podcasts/radio4/thought/thought_20150302-1134a.mp3", 'apikey' => "58fa4fef-c49a-464e-82be-a30aad009099")
puts res.body
