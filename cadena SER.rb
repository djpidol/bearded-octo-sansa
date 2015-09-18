# Cadena Ser rss -> speech to text
# https://twitter.com/DJPDeveloper
#
# tested with ruby 2.0.0 y 2.1.1
# encoding: UTF-8
require 'rexml/document'
require 'open-uri'
require 'uri'
require 'net/http'
require 'json'

# this is a script to show how to connect to IdolOnDemand as a rest service
# and apply speech to text analysis

# insert your api_key here, you can request by registering at
# https://www.idolondemand.com/signup.html
# and then go to Tools->Account->Manage Your API Keys
$api_key= "xxx"

# how long to wait between status requests
$status_wait= 30
# fuente SER
$lol = 'http://urotrosfiles.media.streamtheworld.com/otrosfiles/podcasts/571.xml'

# language for Speech analisis
$audio_language="es-ES"
# language for Sentiment analisis
$sentiment_language="spa"

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
def analyze(title,guid)
  puts "Analysing Item #{title}"
  puts "URL #{guid}"
  sa_content = speech_analysis(guid)[0]['result']['document'][0]['content']
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
##########
## get RSS feed
puts "Retrieving RSS #{$lol}"
  REXML::Document.new(open(URI.parse($lol))).elements.
     each('rss/channel/item') {|item|
        analyze(item.elements['title'].text,
           item.elements['guid'].text)}
