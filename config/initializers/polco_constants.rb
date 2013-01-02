VOTE_VALUES = [:aye, :nay, :abstain, :present]
GROUP_TYPES = [:custom, :state, :district]
GOVTRACK_URL = "http://www.govtrack.us/"
BILL_STATE = YAML.load_file(File.expand_path("#{Rails.root}/config/bill_status.yml", __FILE__))
CHAMBERS = [:house, :senate]
BILL_TYPES = ['h','hr','hj','hc','s','sr','sj','sc']
BILL_STATUS =   {:prov_kill_veto =>"Vetoed (No Override Attempt). <em>Vetoed by the President but the veto can be overridden.</em>",
                 :fail_second_senate =>"Passed House, Failed Senate. <em>Passed the House but failed in the Senate.</em>",
                 :passed_bill =>"At President. <em>The bill passed both chambers of Congress in identical form and goes on to the President for signing next.</em>",
                 :passed_constamend =>"Passed (Constitutional Amendment). <em>The resolution proposing a constitutional amendment passed both chambers of Congress and goes on to the states.</em>",
                 :pass_back_senate =>"Passed Senate with Changes. <em>The Senate passed the bill with changes and sent it back to the House.</em>",
                 :vetoed_override_fail_second_house =>"Vetoed &amp; Override Passed Senate, Failed in House. <em>The Senate overrode the veto but the House's attempt to override the veto failed.</em>",
                 :fail_originating_house =>"Failed House. <em>Failed in the House, its originating chamber</em>",
                 :fail_second_house =>"Passed Senate, Failed House. <em>Passed the Senate but failed in the House.</em>",
                 :override_pass_over_house =>"Vetoed &amp; House Overrides (Senate Next). <em>The House passed a veto override, sending it to the Senate.</em>",
                 :override_pass_over_senate =>"Vetoed &amp; Senate Overridess (House Next). <em>The Senate passed a veto override, sending it to the House.</em>",
                 :pass_back_house =>"Passed House with Changes. <em>The House passed the bill with changes and sent it back to the Senate.</em>",
                 :prov_kill_cloturefailed =>"Failed Cloture. <em>Cloture (ending a filibuster) failed but can be tried again.</em>",
                 :enacted_veto_override =>"Veto Overridden. <em>Enacted by a veto override.</em>",
                 :passed_concurrentres =>"Passed (Concurrent Resolution). <em>The concurrent resolution passed both chambers of Congress (its final status).</em>",
                 :prov_kill_suspensionfailed =>"Failed Under Suspension. <em>Passage failed under 'suspension of the rules' but can be voted on again.</em>",
                 :passed_simpleres =>"Passed (Simple Resolution). <em>The simple resolution was passed (its final status).</em>",
                 :vetoed_pocket =>"Pocket Vetoed. <em>Pocket vetoed by the President.</em>",
                 :vetoed_override_fail_originating_house =>"Vetoed &amp; Override Failed in House. <em>The House's attempt to override a veto failed.</em>",
                 :fail_originating_senate =>"Failed Senate. <em>Failed in the Senate, its originating chamber</em>",
                 :pass_over_senate =>"Passed Senate. <em>Passed the Senate, waiting for a House vote next.</em>",
                 :enacted_signed =>"Signed by the President. <em>Enacted by a signature of the President.</em>",
                 :pass_over_house =>"Passed House. <em>Passed the House, waiting for a Senate vote next.</em>",
                 :prov_kill_pingpongfail =>"Failed to Resolve Differences. <em>The House or Senate failed to resolve differences with the other chamber but can try again.</em>",
                 :reported =>"Reported by Committee. <em>Reported by a committee in the originating chamber.</em>",
                 :vetoed_override_fail_second_senate =>"Vetoed &amp; Override Passed House, Failed in Senate. <em>The House overrode the veto but the Senate's attempt to override the veto failed.</em>",
                 :vetoed_override_fail_originating_senate =>"Vetoed &amp; Override Failed in Senate. <em>The Senate's attempt to override a veto failed.</em>",
                 :introduced =>"Introduced. <em>Introduced but not yet referred to a committee.</em>",
                 :referred =>"Referred to Committee. <em>Referred to a committee in the originating chamber.</em>"}
BILL_TYPE_HASH = {house_resolution: {short_title: 'H.Res..', description: 'House simple resolutions, which do not have the force of law'},
                  senate_bill: {short_title: 'S.', description: 'Senate bills'},
                  senate_joint_resolution: {short_title: 'S.J.Res.', description: 'Joint resolutions originating in the Senate, which may be used to enact laws or propose constitutional amendments'},
                  house_bill: {short_title: 'H.R.', description: 'House bills'},
                  house_concurrent_resolution: {short_title: 'H.Con.Res.', description: 'Concurrent resolutions originating in the House, which do not have the force of law'},
                  senate_concurrent_resolution: {short_title: 'S.Con.Res.', description: 'Concurrent resolutions originating in the Senate, which do not have the force of law'},
                  house_joint_resolution: {short_title: 'H.J.Res.', description: 'Joint resolutions originating in the House, which may be used to enact laws or propose constitutional amendments'},
                  senate_resolution: {short_title: 'S.Res.', description: 'Senate simple resolutions, which do not have the force of law'}}
ROLL_CATEGORIES = {amendment: {
                      description: "Votes on accepting or rejecting amendments to bills and resolutions.",
                      label: "Amendment"},
                   cloture: {
                       description: "Votes to end debate and move to a vote, i.e. to end a filibuster.",
                       label: "Cloture"},
                   conviction: {
                       description: "'Guilty or Not Guilty' votes in the Senate to convict an office holder of impeachment.",
                       label: "Impeachment Conviction"},
                   nomination: {
                       description: "Senate votes on presidential nominations.",
                       label: "Nomination"},
                   other: {
                       description: "A variety of uncategorized votes.",
                       label: "Other"},
                   passage: {
                       description: "Votes on passing or failing bills and resolutions and on agreeing to conference reports.",
                       label: "Passage"},
                   passage_part: {
                       description: "Votes on the passage of parts of legislation.",
                       label: "Passage (Part)"},
                   passage_suspension: {
                       description: "Fast-tracked votes on the passage of bills requiring a 2/3rds majority.",
                       label: "Passage under Suspension"},
                   procedural: {
                       description: "A variety of procedural votes such as quorum calls.",
                       label: "Procedural"},
                   ratification: {
                       description: "Senate votes to ratify treaties.",
                       label: "Treaty Ratification"},
                   unknown: {
                       description: "A variety of uncategorized votes.",
                       label: "Unknown Category"},
                   veto_override: {
                       description: "Votes to override a presidential veto.",
                       label: "Veto Override"}}
API_BILL_TYPES = {"house_resolution" => "H.Res.. <em>House simple resolutions, which do not have the force of law</em>",
              "senate_bill" => "S.. <em>Senate bills</em>",
              "senate_joint_resolution" => "S.J.Res.. <em>Joint resolutions originating in the Senate, which may be used to enact laws or propose constitutional amendments</em>",
              "house_bill" => "H.R.. <em>House bills</em>",
              "house_concurrent_resolution" => "H.Con.Res.. <em>Concurrent resolutions originating in the House, which do not have the force of law</em>",
              "senate_concurrent_resolution" => "S.Con.Res.. <em>Concurrent resolutions originating in the Senate, which do not have the force of law</em>",
              "house_joint_resolution" => "H.J.Res.. <em>Joint resolutions originating in the House, which may be used to enact laws or propose constitutional amendments</em>",
              "senate_resolution" => "S.Res.. <em>Senate simple resolutions, which do not have the force of law</em>"}

CURRENT_STATUS = {"prov_kill_veto" => "Vetoed (No Override Attempt). <em>Vetoed by the President but the veto can be overridden.</em>",
                  "fail_second_senate" => "Passed House, Failed Senate. <em>Passed the House but failed in the Senate.</em>",
                  "passed_bill" => "At President. <em>The bill passed both chambers of Congress in identical form and goes on to the President for signing next.</em>",
                  "passed_constamend" => "Agreed To (Constitutional Amendment). <em>The resolution proposing a constitutional amendment was agreed to by both chambers of Congress and goes on to the states.</em>",
                  "pass_back_senate" => "Passed Senate with Changes. <em>The Senate passed the bill with changes and sent it back to the House.</em>",
                  "vetoed_override_fail_second_house" => "Vetoed &amp; Override Passed Senate, Failed in House. <em>The Senate overrode the veto but the House's attempt to override the veto failed.</em>",
                  "fail_originating_house" => "Failed House. <em>Failed in the House, its originating chamber</em>",
                  "fail_second_house" => "Passed Senate, Failed House. <em>Passed the Senate but failed in the House.</em>",
                  "override_pass_over_house" => "Vetoed &amp; House Overrides (Senate Next). <em>The House passed a veto override, sending it to the Senate.</em>",
                  "override_pass_over_senate" => "Vetoed &amp; Senate Overridess (House Next). <em>The Senate passed a veto override, sending it to the House.</em>",
                  "pass_back_house" => "Passed House with Changes. <em>The House passed the bill with changes and sent it back to the Senate.</em>",
                  "prov_kill_cloturefailed" => "Failed Cloture. <em>Cloture (ending a filibuster) failed but can be tried again.</em>",
                  "enacted_veto_override" => "Veto Overridden. <em>Enacted by a veto override.</em>",
                  "passed_concurrentres" => "Agreed To (Concurrent Resolution). <em>The concurrent resolution was agreed to by both chambers of Congress. This is the final status for concurrent resolutions.</em>",
                  "prov_kill_suspensionfailed" => "Failed Under Suspension. <em>Passage failed under \"suspension of the rules\" but can be voted on again.</em>",
                  "passed_simpleres" => "Agreed To (Simple Resolution). <em>The simple resolution was agreed to in the chamber in which it was introduced. This is a simple resolution's final status.</em>",
                  "vetoed_pocket" => "Pocket Vetoed. <em>Pocket vetoed by the President.</em>",
                  "vetoed_override_fail_originating_house" => "Vetoed &amp; Override Failed in House. <em>The House's attempt to override a veto failed.</em>",
                  "fail_originating_senate" => "Failed Senate. <em>Failed in the Senate, its originating chamber</em>",
                  "pass_over_senate" => "Passed Senate. <em>Passed the Senate, waiting for a House vote next.</em>",
                  "enacted_signed" => "Signed by the President. <em>Enacted by a signature of the President.</em>",
                  "pass_over_house" => "Passed House. <em>Passed the House, waiting for a Senate vote next.</em>",
                  "prov_kill_pingpongfail" => "Failed to Resolve Differences. <em>The House or Senate failed to resolve differences with the other chamber but can try again.</em>",
                  "reported" => "Reported by Committee. <em>Reported by a committee in the originating chamber.</em>",
                  "vetoed_override_fail_second_senate" => "Vetoed &amp; Override Passed House, Failed in Senate. <em>The House overrode the veto but the Senate's attempt to override the veto failed.</em>",
                  "vetoed_override_fail_originating_senate" => "Vetoed &amp; Override Failed in Senate. <em>The Senate's attempt to override a veto failed.</em>",
                  "introduced" => "Introduced. <em>Introduced but not yet referred to a committee.</em>",
                  "referred" => "Referred to Committee. <em>Referred to a committee in the originating chamber.</em>"}
