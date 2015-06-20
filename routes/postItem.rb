require 'sinatra'

class Application < Sinatra::Base

  post '/api/postItem' do
    puts "hi!"
    result = "asd"
  end

end