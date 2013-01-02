# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :roll do
    category "procedural"
    chamber "house"
    chamber_label "House"
    congress 112
    created Date.parse("Wed, 05 Jan 2011 12:34:00 +0000")
    link "http://www.govtrack.us/congress/votes/112-2011/h1"
    number 1
    options {{"+" => "Aye", "-"=>"No", "0"=>"Not Voting", "P"=>"Present"}}
    the_question "Call of the House: QUORUM"
    required "QUORUM"
    resource_uri "/api/v1/vote/1015/"
    result "Passed"
    session "2011"
    source "house"
    source_label "house.gov"
    source_link "http://clerk.house.gov/evs/2011/roll001.xml"
    aye 0
    nay 434
    other 0
    vote_type "Quorum Call"
  end

  #factory :house_roll, class: Roll do
  #  chamber "house"
  #  session 112
  #  result "Passed"
  #  required "1/2"
  #  type "On the Resolution"
  #  bill_type {BILL_TYPES[rand(0..7)]}
  #  the_question {Faker::Lorem.paragraphs(1)}
  #  bill_category {ROLL_CATEGORIES.keys[rand(0..11)].to_s}
  #  aye 225
  #  nay 182
  #  nv 17
  #  present 3
  #  year 2011
  #  congress "112"
  #  original_time Time.parse("2011-01-07 16 04 00 UTC")
  #  updated_time Time.parse("2011-12-05 15 49 06 UTC")
  #  # add bill
  #  bill
  #end
  #
  #factory :senate_roll, class: Roll do
  #  chamber "senate"
  #  session 112
  #  result "Passed"
  #  required "1/2"
  #  type "On the Resolution"
  #  bill_type {BILL_TYPES[rand(0..7)]}
  #  the_question {Faker::Lorem.paragraphs(1)}
  #  bill_category {ROLL_CATEGORIES.keys[rand(0..11)].to_s}
  #  aye 50
  #  nay 48
  #  nv 1
  #  present 1
  #  year 2011
  #  congress "112"
  #  original_time Time.parse("2011-01-07 16 04 00 UTC")
  #  updated_time Time.parse("2011-12-05 15 49 06 UTC")
  #  # add bill
  #  bill
  #end

end
