# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :roll do
    chamber ""
    session ""
    file_name ""
    result ""
    required ""
    type ""
    bill_type ""
    the_question ""
    bill_category ""
    aye ""
    nay ""
    nv ""
    present ""
    year ""
    congress ""
    vote_count ""
    original_time ""
    updated_time ""
  end
end
