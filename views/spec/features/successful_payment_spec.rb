require_relative '../spec_helper'

describe 'A successful payment', js: true, type: :request do
  it 'responds with a success message' do
    visit '/'

    card_number = '4111 1111 1111 1111'
    fill_in 'amount', with: 100
    fill_in 'number', with: card_number
    fill_in 'cvv', with: '123'
    fill_in 'expiration_date', with: '11/2015'

    find_button('Submit').click

    expect(page).to have_content('Payment Success')
    expect(page).not_to have_content(card_number)
   end
end