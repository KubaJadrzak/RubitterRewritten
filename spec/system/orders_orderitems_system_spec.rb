require 'rails_helper'

RSpec.describe 'Order OrderItem System Test', type: :system do
  let(:user) { create(:user) }
  let(:cart) { user.cart }
  let!(:product_in_cart) { create(:product, title: 'This is Product in Cart', price: 15) }
  let!(:other_product_in_cart) { create(:product, title: 'This is other Product in Cart', price: 20) }


  before do
    sign_in user
    driven_by(:selenium_chrome_headless)
  end

  context 'when cart has items' do
    let!(:cart_item) { create(:cart_item, cart: cart, product: product_in_cart) }
    let!(:other_cart_item) { create(:cart_item, cart: cart, product: other_product_in_cart, quantity: 3) }
    it 'user can place order' do
      visit cart_path
      expect(page).to have_content('Your Cart')
      expect(page).to have_content('This is Product in Cart')
      expect(page).to have_content('This is other Product in Cart')
      expect(page).to have_content('$75.00')
      click_link 'Place Order'
      expect(page).to have_content('Email')
      expect(page).to have_content('Shipping Address')

      fill_in 'Shipping Address', with: 'Shipping Address'

      choose('Secure Web Page')
      click_button 'Pay'
      expect(page).to have_current_path(/secure_web_page/, wait: 3)
      order = Order.last
      expect(page).to have_content(order.total_price)
      expect(page).to have_content(order.payment_id)
      expect(page).to have_content(order.order_number)
    end
  end

  context 'when cart is empty' do
    it 'user cannot place order' do
      visit cart_path
      expect(page).to have_content('Your Cart')
      expect(page).to have_content('Your cart is empty.')
      expect(page).to_not have_content('Place Order')
    end
  end

  context 'when user has orders' do
    let!(:order) { create(:order, user: user, order_number: 'qwerty1234') }
    it 'user can visit order show page' do
      visit root_path
      find('img[alt="Account"]').click
      click_button 'Orders'
      expect(page).to have_content('Your Order')
      expect(page).to have_content(order.order_number)
      expect(page).to have_content(order.total_price)

      find('a', text: order.order_number).click
      expect(page).to have_content(order.order_number)
      expect(page).to have_content(order.total_price)
      expect(page).to_not have_content('Your Order')
    end
  end
end
