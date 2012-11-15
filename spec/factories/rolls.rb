# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :roll do
    chamber "house"
    session 112
    result "Passed"
    required "1/2"
    type "On the Resolution"
    bill_type "hr"
    the_question "On Agreeing to the Resolution: H RES 26 Providing for consideration of H.R. 2, to repeal the job-killing health care law and health care-related provisions in the Health Care and Education Reconciliation Act of 2010; and providing for consideration of H.Res. 9, instructing certain committees to report legislation replacing the job-killing health care law"
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
end
