# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :apartment_request do
    first_name "MyString"
    last_name "MyString"
    email "MyString"
    newsletter false
  end
end
