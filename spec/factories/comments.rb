# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    author "MyString"
    author_email "MyString"
    comment_type "MyString"
    content "MyString"
    user_id "MyString"
  end
end
