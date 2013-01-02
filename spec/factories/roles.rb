# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :role do
    congress_numbers [112]
    current true
    description "Representative for New York's 5th congressional district"
    district 5
    enddate Date.parse("Wed, 02 Jan 2013")
    id "28"
    party "Democrat"
    resource_uri "/api/v1/role/28/"
    role_type 1
    role_type_label "Representative"
    senator_class nil
    startdate Date.parse("Wed, 05 Jan 2011")
    state "NY"
    title "Rep."
    title_long "Representative"
    website "http://ackerman.house.gov/"
  end
end
