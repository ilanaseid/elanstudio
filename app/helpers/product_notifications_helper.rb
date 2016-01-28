module ProductNotificationsHelper

  def utm_options(date, link_name, campaign)
    {
      utm_medium: "ProductNotificationEmail",
      utm_source: "#{date}-#{link_name}",
      utm_campaign: "#{campaign}"
    }
  end

end
