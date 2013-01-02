# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :legislator_vote do
    created { Date.parse("2011-03-16 00:00:00 UTC") }
    link "http://www.govtrack.us/congress/votes/112-2011/h183"
    option "+"
    vote_reference nil
    voter_type 3
    resource_uri "/api/v1/vote_voter/28927519/"
    vote_description "House Vote #183"
    value :aye
  end
end
