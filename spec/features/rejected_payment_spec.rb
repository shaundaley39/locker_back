require_relative '../spec_helper'

describe 'A rejected payment', js: true, type: :request do
  it 'responds with a failed message' do
    visit '/'

    card_number = '4111 1111 1111 1111'
    fill_in 'amount', with: 100
    fill_in 'number', with: card_number
    fill_in 'cvv', with: '200'
    fill_in 'expiration_date', with: '11/2015'

    find_button('Submit').click

    expect(page).to have_content('Could not create the transaction')
   end
end