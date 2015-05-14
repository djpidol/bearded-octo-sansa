require "net/http"
require 'json'

api_key= "58fa4fef-c49a-464e-82be-a30aad009099"
text = "It might seem crazy what I'm about to say
Sunshine she's here, you can take a break
I'm a hot air balloon that could go to space
With the air, like I don't care baby by the way

{Uh}

[Chorus:]
Because I'm happy
Clap along if you feel like a room without a roof
Because I'm happy
Clap along if you feel like happiness is the truth
Because I'm happy
Clap along if you know what happiness is to you
Because I'm happy
Clap along if you feel like that's what you wanna do

[Verse 2:]
Here come bad news talking this and that, yeah,
Well, give me all you got, and don't hold it back, yeah,
Well, I should probably warn you I'll be just fine, yeah,
No offense to you, don't waste your time
Here's why

[Chorus]

{Hey
Go
Uh}

[Bridge:]
(Happy)
Bring me down
Can't nothing
Bring me down
My level's too high
Bring me down
Can't nothing
Bring me down
I said (let me tell you now)
Bring me down
Can't nothing
Bring me down
My level's too high
Bring me down
Can't nothing
Bring me down
I said

[Chorus x2]

{Hey
Go
Uh}

(Happy) [repeats]
Bring me down... can't nothing...
Bring me down... my level's too high...
Bring me down... can't nothing...
Bring me down, I said (let me tell you now)

[Chorus x2]

{Hey
C'mon}"

uri = URI("https://api.idolondemand.com/1/api/async/analyzesentiment/v1")
uri.query = URI.encode_www_form({ :text => text, :language => "eng", :apikey => api_key})

res = Net::HTTP.get_response(uri)
obj = JSON.parse(res.body)

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
