Spree::ShipmentHandler.class_eval do       
  private
    def send_shipped_email
      false #ShipmentMailer.shipped_email(@shipment.id).deliver
    end
end      