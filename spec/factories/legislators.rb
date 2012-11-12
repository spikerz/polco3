# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :legislator do
    first_name ""
    last_name ""
    middle_name ""
    religion ""
    pvs_id ""
    os_id ""
    metavid_id ""
    bioguide_id ""
    youtube_id ""
    title ""
    nickname ""
    user_approval ""
    district ""
    state ""
    party ""
    sponsored_count ""
    cosponsored_count ""
    full_name ""
    govtrack_id ""
    start_date ""
  end
end
