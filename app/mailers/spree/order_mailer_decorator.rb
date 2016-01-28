Spree::OrderMailer.class_eval do
  layout 'mailer'
  default :bcc=>Settings.order_mailer_bcc

  def confirm_email(order, resend = false)
    @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
    subject = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
    subject += "#{(ENV['SPREE_SITE_NAME'] || Spree::Store.current.name)} #{Spree.t('order_mailer.confirm_email.subject')} ##{@order.number} - #{Spree::Order.complete.where(email: @order.email).count}#{@order.packaging_indication}"
    mail(to: @order.email, from: Settings.order_mailer_from, subject: subject)
  end

  def cancel_email(order, resend = false)
    @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
    subject = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
    subject += "#{(ENV['SPREE_SITE_NAME'] || Spree::Store.current.name)} #{Spree.t('order_mailer.cancel_email.subject')} ##{@order.number}#{@order.packaging_indication}"
    mail(to: @order.email, from: Settings.order_mailer_from, subject: subject)
  end

  def order_cc(order, resend = false)
    @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
    subject = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
    subject += "#{(ENV['SPREE_SITE_NAME'] || Spree::Store.current.name)} #{Spree.t('new_order_completed')}: #{@order.display_total}"
    mail(to: Settings.order_mailer_cc, from: Settings.order_mailer_from, subject: subject)
  end

end
