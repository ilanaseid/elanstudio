module Trello
  class CreateSpecialOrderCard
    include Sidekiq::Worker
    TRELLO_LIST_ID='5399fad9c3e74a5009f7d053' 
    
    def perform(name, description)
      logger.debug "Creating card with name #{name} and description #{description}"
      card=Trello::Card.create(list_id: TRELLO_LIST_ID, name: name, desc: description)
      logger.debug "Created card #{card}" 
    end
  end
end