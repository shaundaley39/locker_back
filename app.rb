require 'sinatra'
require 'json'
require 'braintree'
require_relative 'helpers/pretty_print.rb'
require_relative 'routes/postItem.rb'
require_relative 'models/item.rb'

before do
  content_type :json
  headers 'Access-Control-Allow-Origin'  => '*', 'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']
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


  # not persisted - a crude and evil hack not worthy
  items = {}
  item1 = Item.new(1, 666, "Berlin", "Beer", "cold and mind-nourishing", 1.50, "beer3.jpg", 22)
  item2 = Item.new(2, 667, "Berlin", "Whisky", "smokey and refined", 10.50, "whisky5.jpg", 22)
  item3 = Item.new(3, 676, "Berlin", "Gin", "sailor juice", 2.50, "gin35.jpg", 22)
  item4 = Item.new(4, 766, "Berlin", "Cider", "drink for the ladies", 1.20, "cider4334.jpg", 22)
  item5 = Item.new(5, 866, "Berlin", "Vodka", "throat burning to foreshadow vomit", 6.50, "vodka435.jpg", 22)
  items = {1 => item1, 2 => item2, 3 => item3, 4 => item4, 5 => item5 }


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
      :amount => item.price
    )
    puts "Did we score? #{result.success?}"
    if result.success?
      items.buyer_id = 57369861        # here we should be using user id, conveyed as part of the post request... but for the demo we only have one user
      item.sold = true
    end
  end

# ITEM m
  # insecure approach - but it'll do for now
  post '/item/new' do
    # e.g. item = Item.new(2, 666, "Berlin", "Beer", "cold and mind-nourishing", 1.50, "aaaa.jpg", 22)
    params = JSON.parse request.body.read
    item = Item.new(params["seller_id"], params["locker_id"], params["city_id"], params["name"], params["description"], params["price"], params["image"], params["buyer_id"])
    items[item_id] = item
  end
  
  # e.g.    /items/Berlin
  get '/items/?:city?' do
    content_type :json
 
    # here, we must instead
    items.select {|k,v| v.sold == false && params[:city] == v.city}.values.map{|v| [v.name, v.description, v.price, v.image]}.to_json
  end
# LOCKER
end
