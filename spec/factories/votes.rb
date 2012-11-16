# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :vote do
    value :aye
    chamber :house
    user {FactoryGirl.create(:random_user)}
    roll {FactoryGirl.create(:roll)}
  end
end
