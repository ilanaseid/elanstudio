Spree::Address.class_eval do 

  before_validation :check_state_fields



  def check_state_fields
    return if country.blank? || !Spree::Config[:address_requires_state]
    if !country.states_required || country.states.blank?
      self.state_id=nil 
    end
  end


end