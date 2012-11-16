FactoryGirl.define do
  factory :legislator do
    bioguide_id 'A000022'
    first_name 'Gary'
    last_name 'Ackerman'
    middle_name 'L.'
    religion 'Jewish'
    pvs_id '26970'
    os_id 'N00001143'
    metavid_id 'Gary_L._Ackerman'
    youtube_id 'RepAckerman'
    title 'Rep.'
    district '5'
    state 'NY'
    party 'Democrat'
    start_date Date.parse('2011-01-05 00:00:00.000000000Z')
    full_name 'Rep. Gary Ackerman [D, NY-5]'
    govtrack_id 400003
  end
end