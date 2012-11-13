
FactoryGirl.define do
  sequence :bill_number
end

FactoryGirl.define do
  factory :bill do
    ignore do
      the_bill_number {FactoryGirl.generate(:bill_number)}
      the_bill_type {['h','s','sr','hr'][rand(4)]}
    end
    congress 112
    bill_number {the_bill_number}
    bill_type {the_bill_type}
    last_updated Date.parse('2012-03-28 00:00:00 UTC')
    bill_state "REPORTED"
    introduced_date Date.parse('2011-12-08 00:00:00 UTC')
    title {"#{the_bill_type}#{the_bill_number}"}
    titles [["short", "This is the short title"], ["official", "This is the official title."]]
    summary {Faker::Lorem.paragraph}
    bill_actions {[["2011-02-17", "Message on Senate action sent to the House."], ["2011-02-16", "Received in the Senate."], ["2011-02-15T14:12:00-05:00", "Motion to reconsider laid on the table Agreed to without objection."], ["2011-02-15T14:06:00-05:00", "Considered as unfinished business."], ["2011-02-15T13:30:00-05:00", "POSTPONED PROCEEDINGS - The Chair put the question on the adoption of the concurrent resolution, and by voice vote, the Chair announced the noes had prevailed. Mr. Woodall objected to the vote on the grounds that a quorum was not present. Further proceedings on the motion were postponed. The point of no quorum was withdrawn."], ["2011-02-15T13:28:00-05:00", "Considered as privileged matter."]]}
    bill_html {Faker::Lorem.paragraphs(10).join("\n")}
    ident {"112-#{the_bill_type}#{the_bill_number}"}
    cosponsors_count 0
    govtrack_id {"#{the_bill_type}112-#{the_bill_number}"}
    govtrack_name {"#{the_bill_type}#{the_bill_number}"}
    summary_word_count 286
    text_word_count 4976
    text_updated_on Date.parse('2012-04-27 00:00:00 UTC')
    hidden nil
    roll_time nil
    sponsor_id nil
    cosponsor_ids []
    subject_ids []
  end
end
