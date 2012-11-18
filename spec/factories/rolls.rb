# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :roll do
    chamber "house"
    session 112
    result "Passed"
    required "1/2"
    type "On the Resolution"
    bill_type {BILL_TYPES[rand(0..7)]}
    the_question {Faker::Lorem.paragraphs(1)}
    bill_category "passage"
    aye 236
    nay 181
    nv 15
    present 2
    year 2011
    congress "112"
    original_time Time.parse("2011-01-07 16 04 00 UTC")
    updated_time Time.parse("2011-12-05 15 49 06 UTC")
    # add bill
    bill
  end

  factory :house_roll, class: Roll do
    chamber "house"
    session 112
    result "Passed"
    required "1/2"
    type "On the Resolution"
    bill_type {BILL_TYPES[rand(0..7)]}
    the_question {Faker::Lorem.paragraphs(1)}
    bill_category {ROLL_CATEGORIES.keys[rand(0..11)].to_s}
    aye 225
    nay 182
    nv 17
    present 3
    year 2011
    congress "112"
    original_time Time.parse("2011-01-07 16 04 00 UTC")
    updated_time Time.parse("2011-12-05 15 49 06 UTC")
    # add bill
    bill
  end

  factory :senate_roll, class: Roll do
    chamber "senate"
    session 112
    result "Passed"
    required "1/2"
    type "On the Resolution"
    bill_type {BILL_TYPES[rand(0..7)]}
    the_question {Faker::Lorem.paragraphs(1)}
    bill_category {ROLL_CATEGORIES.keys[rand(0..11)].to_s}
    aye 50
    nay 48
    nv 1
    present 1
    year 2011
    congress "112"
    original_time Time.parse("2011-01-07 16 04 00 UTC")
    updated_time Time.parse("2011-12-05 15 49 06 UTC")
    # add bill
    bill
  end

end
