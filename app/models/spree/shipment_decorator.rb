Spree::Shipment.class_eval do 

private 

  def send_shipped_email
    puts "Overriding shipment email, ship station does that #{__FILE__} #{__LINE__}"
  end

end