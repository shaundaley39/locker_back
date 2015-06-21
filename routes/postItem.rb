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
  	puts request_payload;
		File.open('public/item_id.jpg', 'wb') do|f|
			b64=request_payload['image']
			truncated= b64['data:image/jpeg;base64,'.length .. -1]
  		f.write(Base64.decode64(truncated))
		end
  end

end