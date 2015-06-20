require 'sinatra'
require 'braintree'
require_relative 'helpers/pretty_print.rb'
require 'json'

class Application < Sinatra::Base
  helpers Demo::PrettyPrint

  Braintree::Configuration.environment = :sandbox
  Braintree::Configuration.merchant_id = 'ffdqc9fyffn7yn2j'
  Braintree::Configuration.public_key = 'qj65nndbnn6qyjkp'
  Braintree::Configuration.private_key = 'a3de3bb7dddf68ed3c33f4eb6d9579ca'

  get '/' do
        erb :index
  end

  get '/.json' do
    content_type :json
    return {:cities=> ["Amsterdam", "San Francisco", "Berlin", "New York", "Tokyo", "London"]}.to_json
    content_type :html
    erb :index
  end

  post '/process' do
    result = Braintree::Transaction.sale(
      amount: params[:amount],
      order_id: rand(1..1000),
      credit_card: {
        number: params[:number],
        cvv: params[:cvv],
        expiration_date: params[:expiration_date],
      },
      options: {
        submit_for_settlement: true
      },
    )

    if result.success?
      @transaction = result.transaction
      erb :process
    else
      'Could not create the transaction'
    end
  end
end
