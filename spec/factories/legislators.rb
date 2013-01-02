FactoryGirl.define do
  factory :legislator do
    bioguideid "A000022"
    birthday Date.parse("Thu, 19 Nov 1942")
    current_role {FactoryGirl.build(:role)}
    firstname 'Gary'
    gender 1
    lastname 'Ackerman'
    link 'http://www.govtrack.us/congress/members/gary_ackerman/400003'
    metavidid 'Gary_L._Ackerman'
    middlename 'L.'
    name 'Rep. Gary Ackerman [D-NY5]'
    name_no_details 'Gary Ackerman'
    namemod ''
    nickname 'Gary'
    osid 'N00001143'
    pvsid '26970'
    resource_uri '/api/v1/person/400003/'
    sortname "Ackerman, Gary (Rep.) [D-NY5]"
    twitterid 'data'
    youtubeid "RepAckerman"
  end
end