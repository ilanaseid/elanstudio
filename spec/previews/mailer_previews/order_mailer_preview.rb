class Spree::OrderMailerPreview < ActionMailer::Preview

  # TO VIEW: http://localhost:5000/rails/mailers/

  def order_cc
    @order = Spree::Order.find(43489)
    Spree::OrderMailer.order_cc(@order.id)
  end
#
  def cancel_email
    @order = Spree::Order.find(43489)
    Spree::OrderMailer.cancel_email(@order.id)
  end

  def confirm_email
    @order = Spree::Order.find(43489)
    Spree::OrderMailer.confirm_email(@order.id)
  end

end
