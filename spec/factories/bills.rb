# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :bill do
    bill_resolution_type "resolution"
    bill_type "house_resolution"
    congress 112
    current_status "passed_simpleres"
    current_status_date Date.parse("Wed, 05 Jan 2011")
    current_status_description "This simple resolution was agreed to on January 5, 2011. That is the end of the legislative process for a simple resolution."
    current_status_label "Agreed To (Simple Resolution)"
    display_number "H.Res. 1"
    docs_house_gov_postdate nil
    govtrack_id "76416"
    introduced_date Date.parse("Wed, 05 Jan 2011")
    is_alive false
    is_current true
    link "http://www.govtrack.us/congress/bills/112/hres1"
    number 1
    resource_uri "/api/v1/bill/76416/"
    senate_floor_schedule_postdate nil
    sponsor {FactoryGirl.build(:legislator)}
    thomas_link "http://thomas.loc.gov/cgi-bin/bdquery/z?d112:hres1:"
    title "H.Res. 1: Electing officers of the House of Representatives."
    title_without_number "Electing officers of the House of Representatives."
  end
end
