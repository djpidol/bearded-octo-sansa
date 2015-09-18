# thought for the day rss -> speech to text
# https://twitter.com/DJPDeveloper
#
# tested with ruby 2.0.0 y 2.1.1

require 'net/http'
require 'json'
#require 'rss'
# require 'open-uri'

# this is a script to show how to connect to IdolOnDemand as a rest service
# and apply speech to text analysis

# insert your api_key here, you can request by registering at
# https://www.idolondemand.com/signup.html
# and then go to Tools->Account->Manage Your API Keys
$api_key= "afb65d0b-4658-4ffe-9485-5e14b4331ab7"

# how long to wait between status requests
$status_wait= 30
# fuente SER

$media_items = [[:title => 'Andrea Levy: "Lo más importante es que la situación se reconduzca"',
  :link => "http://sdmedia.playser.cadenaser.com/Podcast/2015/7/6/000WB0607820150706013923.mp3"],
  [:title => 'Jordi Sevilla: "El resultado del referéndum no tiene vuelta de hoja"',
  :link => "http://sdmedia.playser.cadenaser.com/Podcast/2015/7/6/000WB0607820150706013756.mp3"],
  [:title => 'Alberto Garzón: "No se puede construir una Unión Europea en contra de la gente"',
  :link => "http://sdmedia.playser.cadenaser.com/Podcast/2015/7/6/000WB0607820150706013228.mp3"],
  [:title => 'Miguel Urbán: "Lo importante al final es lo que dice y construye la gente"',
  :link => "http://sdmedia.playser.cadenaser.com/Podcast/2015/7/6/000WB0607820150706012913.mp3"]]
# language for Speech analisis
$audio_language="es-ES"
# language for Sentiment analisis
$sentiment_language="spa"

# setup proxy
$proxy_addr = 'proxy.gre.hp.com'
$proxy_port = 8080


##########
## get RSS feed
#def get_media_items(url)
#  uri = URI.parse(url)
#  puts "Retrieving RSS #{$rss_source}"
#    feed = RSS::Parser.parse(uri.open(:proxy => "http://"+$proxy_host+":"+$proxy_port+"/"))
#  return feed.items
#end

##########
## wait for a REST request
def wait_on_status(jobid)
  uri = URI("http://api.idolondemand.com/1/job/status/" + jobid)
  uri.query = URI.encode_www_form(:apikey => $api_key)
  res = Net::HTTP.get_response(uri)#, p_addr = $proxy_host, p_port = $proxy_port)
  obj = JSON.parse(res.body)

  if obj['status'] == 'queued'
    puts "job [#{jobid}] #{obj['status']}, waiting #{$status_wait} seconds"
    sleep($status_wait)
    wait_on_status(jobid)
  end
end

##########
## retrieve results of a job
def job_results(jobid)
  wait_on_status(jobid)
  puts "Retrieving results for job [#{jobid}]"
  uri = URI("http://api.idolondemand.com/1/job/result/" + jobid)
  uri.query = URI.encode_www_form(:apikey => $api_key)
  res = Net::HTTP.get_response(uri)#, p_addr = $proxy_host, p_port = $proxy_port)
  return JSON.parse(res.body)['actions']
end

##########
## POST a new job and wait for results
def iod_request (api, params)
  #puts ("api[#{api}]")
  #puts ("params[#{params}]")
  uri = URI("http://api.idolondemand.com/1/api/async/#{api}/v1")
  uri.query = URI.encode_www_form(params)
  #puts ("uri[#{uri}]")
  res = Net::HTTP.get_response(uri)#, p_addr = $proxy_host, p_port = $proxy_port)
  jobid = JSON.parse(res.body)['jobID']
  puts "Post request jobid [#{jobid}]"
  return job_results(jobid)
end

##########
## Run Sentiment Analysis on a text string
def sentiment(text)
  return iod_request('analyzesentiment',
    {:text => text, :language => $sentiment_language, :apikey => $api_key})
end

##########
## Run Speech Analysis on a media asset
def speech_analysis(url)
  return iod_request('recognizespeech',
    {:url => url, :language => $audio_language, :apikey => $api_key})
end

##########
## Format output
def analyze(item)
  puts "Analysing Item #{item[0][:title]}"
  puts "URL #{item[0][:link]}"
  sa_content = speech_analysis(item[0][:link])[0]['result']['document'][0]['content']
  # serialize to debug the data structure
  #File.open('sa_res', 'w+') do |f|
  #  Marshal.dump(sa_res, f)
  #end
  puts "Speech Analysis => #{sa_content}"
  puts "Sentiment => #{sentiment(sa_content)[0]['result']}"
end

##########
# main starts here
#Net::HTTP.new('api.idolondemand.com', nil, $proxy_addr, $proxy_port).start { |http|
  # always proxy via your.proxy.addr:8080
puts "Get media Items from RSS feed and analyze them voice->text->sentiment"
  $media_items.each {|item|
  analyze(item)}
#}
