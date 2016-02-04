class UserMailer < ActionMailer::Base
  add_template_helper(ProductNotificationsHelper)

  default from: "Elan Studio <ilana@elanstudio.com>"
  default bcc: "ilana@elanstudio.com"

  def product_notification(email, notifications)
    @notifications = notifications
    @more_than_one = @notifications.length > 1
    @first_product = Spree::Variant.find(notifications.first.spree_variant_id).product.cms_product
    @brand = @first_product.brand
    @related = @first_product.related(2)
    @chapter = ClearCMS::Site.first.contents.published.where(:_type=>'Chapter').first
    @date_integer = "#{Date.today.month}#{Date.today.day}#{Date.today.year}"
    @campaign = "ProductNotificationsV1"

    mail(to: email, subject: product_notification_subject)
  end

  private

  def product_notification_subject
    @more_than_one ? "Back in Stock: #{@brand.title} and More" : "Back in Stock: #{@brand.title} #{@first_product.title}"
  end

end
