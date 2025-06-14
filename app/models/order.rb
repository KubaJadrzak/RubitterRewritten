# typed: strict

class Order < ApplicationRecord
  extend T::Sig
  belongs_to :user, optional: true, touch: true
  has_many :order_items, dependent: :destroy

  validates :email, presence: true
  validates :total_price, presence: true
  validates :status, presence: true
  validates :shipping_address, presence: true
  validates :ordered_at, presence: true
  validate :must_have_order_items

  before_create :generate_order_number

  broadcasts_refreshes

  sig { params(cart: Cart).void }
  def build_order_items_from_cart(cart)
    cart.cart_items.each do |cart_item|
      order_items.build(
        product:           cart_item.product,
        quantity:          cart_item.quantity,
        price_at_purchase: T.must(cart_item.product).price,
      )
    end
  end

  STATUS_MAP = T.let({
                       'executed'              => 'Preparing for Shipment',
                       'rejected'              => 'Payment Rejected',
                       'failed'                => 'Payment Failed',
                       'resigned'              => 'Payment Resigned',
                       'reversed'              => 'Payment Reversed',
                       'preauthorized'         => 'Waiting for Payment',
                       'tds2_challenge'        => 'Waiting for Payment',
                       'tds_redirected'        => 'Waiting for Payment',
                       'dcc_decision'          => 'Waiting for Payment',
                       'blik_redirected'       => 'Waiting for Payment',
                       'transfer_redirected'   => 'Waiting for Payment',
                       'new'                   => 'Waiting for Payment',
                       'refunded'              => 'Payment Refunded',

                       'timeout'               => 'Awaiting Payment',
                       'connection_failed'     => 'Awaiting Payment',
                       'ssl_error'             => 'Awaiting Payment',
                       'parsing_error'         => 'Awaiting Payment',
                       'unknown_faraday_error' => 'Awaiting Payment',
                       'unexpected_error'      => 'Awaiting Payment',

                       'invalid_uri'           => 'Payment Error',
                     }, T::Hash[String, String],)

  sig { params(payment_status: String).returns(T::Boolean) }
  def update_status_by_payment_status(payment_status)
    new_status = STATUS_MAP[payment_status] || 'Payment Error'
    update(payment_status: payment_status, status: new_status)
  end

  sig { params(payment_status: String).returns(String) }
  def show_status_by_payment_status(payment_status)
    STATUS_MAP[payment_status] || 'Payment Error'
  end

  sig { void }
  def generate_order_number
    self.order_number = SecureRandom.hex(10).upcase
  end

  sig { void }
  def must_have_order_items
    return unless order_items.empty?

    errors.add(:order_items, 'order must have at least one item.')
  end

end
