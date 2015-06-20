require 'sinatra'
require 'braintree'
require_relative 'helpers/pretty_print.rb'
require 'json'

class Application < Sinatra::Base
  helpers Demo::PrettyPrint

  Braintree::Configuration.environment = :sandbox
  Braintree::Configuration.merchant_id = 'x5k5hw2qskhtc7tt'
  Braintree::Configuration.public_key = 'csfcqr83rr7htjj3'
  Braintree::Configuration.private_key = '57116180e9494437aec573851fead6d5'

  # junk
#  get('/', :provides => 'text/html') do
#    erb :index
#  end
#  # junk
#  get('/', :provides => 'application/json') do
#    content_type :json
#    return {:cities=> ["Amsterdam", "San Francisco", "Berlin", "New York", "Tokyo", "London"]}.to_json
#  end

   # depricated 
#  get('/client_token', :provides => 'text/html') do
#    # client_token
#    Braintree::ClientToken.generate()
#  end
#  get('/client_token', :provides => 'application/json') do
#    # client_token
#    content_type :json
#    Braintree::ClientToken.generate().to_json
#  end

  # create user
  post ('/user/new') do
    params = JSON.parse request.body.read
    result = Braintree::Customer.create(
      :first_name => params["first_name"],
      :last_name => params["last_name"],
      :email => params["email"]
    )
    if result.success?
        puts "customer id: #{result.customer.id}"
        return result.customer.id.to_json
      # to do: persist user_id
    else
        p result.errors
    end
  end

  # get token
  get '/user/?:user_id?/client_token' do
    # to do: should validate user id
    content_type :json
    Braintree::ClientToken.generate(:customer_id => params[:user_id]).to_json
  end

  # post payment method to user
  post '/user/?:user_id?/payment_method/new' do
    params = JSON.parse request.body.read
    result = Braintree::PaymentMethod.create(
      :customer_id => params[:user_id],
      :payment_method_nonce => params["payment_method_nonce"]
    )
  end

  # make sale
end
