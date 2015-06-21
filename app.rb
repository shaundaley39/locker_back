require 'sinatra'
require 'json'
require 'braintree'
require_relative 'helpers/pretty_print.rb'
require_relative 'routes/postItem.rb'
require_relative 'models/item.rb'


class Application < Sinatra::Base
  helpers Demo::PrettyPrint
  set :public_folder, 'public'


  before do
     content_type :json
    headers 'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']
  end


  Braintree::Configuration.environment = :sandbox
  Braintree::Configuration.merchant_id = 'x5k5hw2qskhtc7tt'
  Braintree::Configuration.public_key = 'csfcqr83rr7htjj3'
  Braintree::Configuration.private_key = '57116180e9494437aec573851fead6d5'

  options "*" do
    response.headers["Allow"] = "HEAD,GET,PUT,DELETE,OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
  end

  items = []

  # get token
  get '/user/?:user_id?/client_token' do
    # to do: should validate user id
    content_type :json
    Braintree::ClientToken.generate(
      :customer_id => params[:user_id]
      ).to_json
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


  # from customer id, setup a transaction
  # make sale
  post '/item/?:item_id?/buy' do
   # params = JSON.parse request.body.read
    # we should look up the item by id, and obtain its price to use as amount for transaction below
    item = items[ params[:item_id] ]
    customer = Braintree::Customer.find("57369861")    #"#{params["user_id"]}")
    payment_method_token = customer.credit_cards.first.token
    result = Braintree::Transaction.sale(
      :payment_method_token => payment_method_token,
      :amount => item.itemPrice
    )
    puts "result: #{result.success?}"

    if result.success?
      items.buyer_id = 57369861        # here we should be using user id, conveyed as part of the post request... but for the demo we only have one user
      item.sold = true
    end
  end

  # insecure approach - but it'll do for now
  post '/api/postItem' do
    # e.g. item = Item.new(2, 666, "Berlin", "Beer", "cold and mind-nourishing", 1.50, "aaaa.jpg", 22)

    request.body.rewind
    params = JSON.parse request.body.read
    # puts request_payload;

    a=items.push ({
      :lockerCode => params["lockerCode"],
      :itemName => params["itemName"],
      :location => params["location"],
      :description => params["description"],
      :itemPrice => params["itemPrice"],
      :image => params["image"],
      :sellerId => params["sellerId"] })


    puts items.to_json

    File.open('public/image.jpg', 'wb') do|f|

      b64=params['image']
      truncated= b64['data:image/jpeg;base64,'.length .. -1]
      f.write(Base64.decode64(truncated))

    end

    return params.to_json
  end
  # e.g.    /items/Berlin
  get '/api/items/?:city?' do
    content_type :json
    puts items
    # here, we must instead
    return items.to_json
  end
# LOCKER
end



  # # create user
  # post ('/user/new') do
  #   params = JSON.parse request.body.read
  #   result = Braintree::Customer.create(
  #     :first_name => params["first_name"],
  #     :last_name => params["last_name"],
  #     :email => params["email"]
  #   )
  #   if result.success?
  #       puts "customer id: #{result.customer.id}"
  #       return result.customer.id.to_json
  #     # to do: persist user_id
  #   else
  #       p result.errors
  #   end
  # end
