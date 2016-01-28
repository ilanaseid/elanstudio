class SeedMailChimpProductionGroups < ActiveRecord::Migration
  def change

    if (apartment_list = EmailList.unscoped.find_by(mailchimp_list_id: '06f85ee271'))
      EmailInterestGroup.create(email_list: apartment_list, mailchimp_grouping_id: 7341, display_name: "The Apartment – New York", short_description: "Get to know our offline home in SoHo and receive invitations to upcoming events, activities, and special sales.", mailchimp_name: "The Apartment – New York", mailchimp_id: 9)
      EmailInterestGroup.create(email_list: apartment_list, mailchimp_grouping_id: 7341, display_name: "The Apartment – Los Angeles", short_description: "Get to know our offline home in West Hollywood and receive invitations to upcoming events, activities, and special sales.", mailchimp_name: "The Apartment – Los Angeles", mailchimp_id: 13)
    end
    # irb(main):009:0> MAILCHIMP.lists.interest_groupings(id: list_id)
    # => [{"id"=>7341, "name"=>"The Apartment Locations", "form_field"=>"checkboxes", "display_order"=>"0", "groups"=>[{"id"=>9, "bit"=>"1", "name"=>"The Apartment – New York", "display_order"=>"1", "subscribers"=>nil}, {"id"=>13, "bit"=>"2", "name"=>"The Apartment – Los Angeles", "display_order"=>"2", "subscribers"=>nil}]}
  end
end
