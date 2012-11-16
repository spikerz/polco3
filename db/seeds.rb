# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts 'EMPTY THE MONGODB DATABASE'
require 'database_cleaner'
DatabaseCleaner.clean
#Mongoid.master.collections.reject { |c| c.name =~ /^system/}.each(&:drop)

puts 'create the common polco_group'

PolcoGroup.find_or_create_by(name: 'Polco Common', description: 'common group for all of polco', type: :common)

PolcoGroup.find_or_create_by(:name => "unaffiliated", :type => :custom)
PolcoGroup.find_or_create_by(:name => "foreign", :type => :custom)

districts_array = File.new("#{Rails.root}/data/districts.txt", 'r').read.split("\n")

states = districts_array.map { |d| d.slice(0, 2) }.uniq.sort

puts 'creating states'
states.each do |state|
  PolcoGroup.find_or_create_by(:name => state, :type => :state)
end

puts 'creating districts'
districts_array.each do |district|
  # create district for each state
  PolcoGroup.find_or_create_by(:name => district, :type => :district)
end

