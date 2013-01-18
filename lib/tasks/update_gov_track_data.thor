class UpdateGovTrackData < Thor

  ENV['RAILS_ENV'] ||= 'development'
  # require "#{Rails.roo/config/environment.rb"
  require File.expand_path('config/environment.rb')
  require 'database_cleaner'

  # rake db:seed
  # load_legislators
  # update_from_directory
  # update_rolls

  desc "load_all", "seeds all data"
  def load_all
    DatabaseCleaner.clean
    system('rake db:seed')
    load_legislators
    #update_from_directory
    #update_rolls
  end

  desc "load_rolls", "loads all rolls"
  def load_rolls
    Roll.pull_in_votes(300)
  end

  desc "load_legislators", "loads all members"
  def load_legislators
    Legislator.update_legislators
  end

  desc "update_from_directory", "updates all bills from directory"
  def update_from_directory
    Dir.glob("#{DATA_PATH}/bills/*.xml").each do |bill_path|
      bill_name = bill_path.match(/.*\/(.*).xml$/)[1]
      puts "processing #{bill_name}"
      b = Bill.find_or_create_by(:title => bill_name, :govtrack_name => bill_name)
      b.update_bill
      b.save!
    end
  end

  desc "pull_out", "pull out rolled bills"
  def pull_out
    pattern = /<bill session="(\d+)" type="(\w+)" number="(\d+)" \/>/
    count = 0
    # "h", "hr", "hj", "hc"
    # "s", "sr", "sj", "sc"
    Dir.glob("#{Rails.root}/data/rolls/*.xml").each do |file|
      File.open(file) do |f|
        f.each_line do |line|
          if line.match(pattern) && count < 100 && File.basename(file).first == "s"
            bill_type = $2
            if ["s", "sr", "sj", "sc"].include?(bill_type)
              count = count + 1
              number = $3   # NOT
              bill_name = "#{bill_type}#{number}.xml"
              # Bill files are named as follows: data/us/CCC/rolls/TTTNNN.xml.
              # TTT = type of resolution
              # NNN = bill number with zero padding
              puts bill_type
              FileUtils.copy(file,"#{Rails.root}/spec/test_data/rolls/")
              FileUtils.copy("#{Rails.root}/data/bills/#{bill_name}","#{Rails.root}/spec/test_data/bills/")
            end
          end
        end
      end
    end
  end

  desc "update_rolls", "update the rolls of all bills"
  def update_rolls
    Dir.glob("#{DATA_PATH}/rolls/*.xml").sort_by { |f| f.match(/\/.+\-(\d+)\./)[1].to_i }.each do |bill_path|
      Roll.bring_in_roll(File.basename(bill_path))
    end
  end

end
