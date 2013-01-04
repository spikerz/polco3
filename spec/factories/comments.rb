# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    author "tim"
    author_email "tim@theboohers.org"
    comment_type "MyString"
    content "I love this place. It is sweet."
    user_ip "192.168.1.102"
  end
end
