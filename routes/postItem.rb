require 'sinatra'
require 'sinatra/cross_origin'
require 'json'

class Application < Sinatra::Base

before do
   content_type :json
   headers 'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']
end

  post '/api/postItem' do
	 	request.body.rewind
  	request_payload = JSON.parse request.body.read
  	result =  request_payload.to_json
  end

end