require 'sinatra'
require 'json'
require 'braintree'
require_relative 'helpers/pretty_print.rb'
require_relative 'routes/postItem.rb'

before do
   content_type :json
   headers 'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']
end

class Application < Sinatra::Base
  helpers Demo::PrettyPrint
  set :public_folder, 'public'

  Braintree::Configuration.environment = :sandbox
  Braintree::Configuration.merchant_id = 'x5k5hw2qskhtc7tt'
  Braintree::Configuration.public_key = 'csfcqr83rr7htjj3'
  Braintree::Configuration.private_key = '57116180e9494437aec573851fead6d5'

# USER - minimum
  options "*" do
    response.headers["Allow"] = "HEAD,GET,PUT,DELETE,OPTIONS"
    # Needed for AngularJS
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
  end


  # junk
 # get '/' do
 #   erb :index
 # end

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
  # post '/user/?:user_id?/payment_method/new'
  # end
  post '/user/?:user_id?/payment_method/new' do
    params = JSON.parse request.body.read
    result = Braintree::PaymentMethod.create(
      :customer_id => params[:user_id],
      :payment_method_nonce => params["payment_method_nonce"]
    )
    # to do: this result should be a payment token - and we need to persist this
#    puts result.payment_method_token # does this work
  end


# EXPERIMENTAL GAMES
  # from customer id, setup a transaction
  post '/magic/item/?:item_id?/buy' do
    params = JSON.parse request.body.read
    customer = Braintree::Customer.find("#{params["user_id"]}")
    payment_method_token = customer.credit_card.payment_method_token   # this requires modification - probably
    payment_method = Braintree::PaymentMethod.find("payment_method_token")

  end

  # make sale
  post '/item/?:item_id?/buy' do
    params = JSON.parse request.body.read
    # for our current user, get :token from persisted place...
    # price =... lookup item by params[:item_id] and extract price
    # payment_method = Braintree::PaymentMethod.find( :token)
  end


# ITEM m


# LOCKER
end
