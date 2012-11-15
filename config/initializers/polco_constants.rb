VOTE_VALUES = [:aye, :nay, :abstain, :present]
GOVTRACK_URL = "http://www.govtrack.us/"
BILL_STATE = YAML.load_file(File.expand_path("#{Rails.root}/config/bill_status.yml", __FILE__))