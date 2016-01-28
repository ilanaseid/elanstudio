Spree::Order.state_machine.after_transition :to => :complete do |order|
  CMS::UpdateOnOrder.perform_async(order.id)
  Brightpearl::SubmitOrder.perform_async(order.id)
  Spree::OrderMailer.delay.order_cc(order.id)
  Spree::FraudChecker.perform_async(order.id)
end

Spree::Order.class_eval do

  has_many :line_items, -> { order('updated_at DESC')}, dependent: :destroy
  has_one :gift_detail, foreign_key: 'spree_order_id'
  has_one :retail_staff_order_detail, foreign_key: 'spree_order_id'
  accepts_nested_attributes_for :gift_detail
  accepts_nested_attributes_for :retail_staff_order_detail, :reject_if=>:all_blank, allow_destroy: true
  # TODO: review :payment_due scope, 2nd half would never run
  scope :payment_due, -> { where(:payment_state => 'balance_due') || payments.pending.any? }
  scope :failed_payment, -> { where(:payment_state => 'failed') }

  def gift?
    gift_detail && gift_detail.message.present?
  end

  def international?
    ship_address && (ship_address.country.iso3 != 'USA')
  end

  def self.incomplete
    where(completed_at: nil).includes(:line_items => {:product => [:taxons], :variant => [:product, :option_values, :stock_items, :shipping_category]})
  end

  def deliver_order_confirmation_email
    Spree::OrderMailer.delay.confirm_email(self.id)
    update_column(:confirmation_delivered, true)
  end

  def packaging_indication
    luxury_packaging ? "S" : "M"
  end

  def signed_in?
    Spree::User.exists?(email: email) && user
  end

  def guest?
    !signed_in?
  end

end
