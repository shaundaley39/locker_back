require 'sinatra'
require 'sinatra/cross_origin'

class Application < Sinatra::Base
before do
   content_type :json
   headers 'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']
end

  post '/api/postItem' do
    puts "hi!"
    result = {result: "asd"}.to_json
  end

end