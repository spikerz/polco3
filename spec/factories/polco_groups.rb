# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :polco_group do
    name "MyString"
    type ""
    description "MyString"
    vote_count 1
    follower_count 1
    member_count 1
  end
end
