# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :bill do
    congress ""
    bill_number ""
    bill_type ""
    last_updated ""
    bill_state ""
    introduced_date ""
    title ""
    titles ""
    summary ""
    bill_actions ""
    bill_html ""
    ident ""
    cosponsors_count ""
    govtrack_id ""
    govtrack_name ""
    summary_word_count ""
    text_word_count ""
    text_updated_on ""
    hidden ""
    roll_time ""
  end
end
