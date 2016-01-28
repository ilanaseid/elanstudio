class Apartment
  class VisitNotifier
    include Sidekiq::Worker
  
    def perform(apartment_visit_id)
      visit=ApartmentVisit.find(apartment_visit_id)
      ApartmentMailer.email_apartment(visit).deliver
    end
    
  end
end