# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :support_request do
    email "MyString"
    comment "MyText"
  end
end
