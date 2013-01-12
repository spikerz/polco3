# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :user do
    provider "developer"
    name "Leopold"
    email "leopold@habsburgfamily.es"
    custom_groups {[FactoryGirl.create(:polco_group)]}
    state {FactoryGirl.create(:oh)}
    district {FactoryGirl.create(:district)}
  end

  factory :random_user, class: User do
    name {Faker::Name.name}
    email {Faker::Internet.email}
    custom_groups []
    common_groups []
    district nil
    state nil
  end

end