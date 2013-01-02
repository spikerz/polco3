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
    aye 30
    nay 404
    other 0
    vote_type "Quorum Call"
    bill
  end

  factory :house_roll, class: Roll do
    chamber "house"
  end

  factory :senate_roll, class: Roll do
    chamber "senate"
    chamber_label "Senate"
    source "senate"
  end

end
