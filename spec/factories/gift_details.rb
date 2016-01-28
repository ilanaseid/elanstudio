# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :gift_detail do
    spree_order_id 1
    to "MyString"
    from "MyString"
    message "MyText"
  end
end
