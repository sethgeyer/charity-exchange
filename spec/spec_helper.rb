# require_relative "./../app"
# require "capybara/rspec"
# ENV["RACK_ENV"] = "test"
#
# Capybara.app = App
#
# RSpec.configure do |config|
#   config.before do
#     database_connection = GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])
#
#     database_connection.sql("BEGIN")
#   end
#
#   config.after do
#     database_connection = GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])
#
#     database_connection.sql("ROLLBACK")
#
#     ### Added the below code to empty out the various table after each test is run. The rollback call above was not working.
#     tables = ['accounts', 'charities', 'deposits', 'distributions', 'mvps', 'proposed_wagers', 'users']
#     tables.each { |table| database_connection.sql("DELETE FROM #{table} WHERE ID > 0 ") }
#
#   end
# end

require_relative "./../app"
require "capybara/rspec"
require "database_cleaner"
ENV["RACK_ENV"] = "test"

Capybara.app = App

RSpec.configure do |config|

  config.before(:suite) do
    GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end



def fill_in_registration_form(name)
  ssn = rand(100000000..199999999)
  visit "/users/new"
  fill_in "Username", with: "#{name.downcase}y"
  fill_in "SSN", with: ssn
  fill_in "Email", with: name
  fill_in "Password", with: name.downcase
  fill_in "Confirm", with: name.downcase
  fill_in "Profile Picture", with: "http://google.com"
  click_on "Submit"

end


def login_a_registered_user(name)
  fill_in "username", with: "#{name.downcase}y"
  fill_in "Password", with: name.downcase
  click_on "Login"
end

def complete_application(charity_name)
  fill_in "Charity Name", with: charity_name
  fill_in "Federal Tax ID", with: 123456789
  fill_in "Primary POC", with: "Al Smith"
  fill_in "POC Email", with: "alsmith@gmail.com"
  click_on "Submit"
end

def fund_my_account_with_a_credit_card(deposit_amount)
  click_on "Fund My Account"
  fill_in "Amount", with: deposit_amount
  fill_in "Credit Card Number", with: 123456789
  fill_in "Exp Date", with: "2014-07-31"
  fill_in "Name on Card", with: "Stephen Geyer"
  within(page.find("#new_deposits")) { choose "Visa" }
  click_on "Submit"
end

def distribute_funds_from_my_account(distribution_amount, charity)
  click_on "Distribute Funds"
  fill_in "Amount", with: distribution_amount
  select charity, from: "charity_dd"
  click_on "Submit"
end

def register_and_create_a_wager
  fill_in_registration_form("Alexander")
  click_on "Logout"
  fill_in_registration_form("Stephen")
  fund_my_account_with_a_credit_card(400)
  visit "/proposed_wagers/new"
  fill_in "Title", with: "Ping Pong Match between S & A"
  fill_in "Date of Wager", with: "2014-07-31"
  fill_in "Details", with: "Game to 21, standard rules apply"
  fill_in "Amount", with: 100
  select "Alexander", from: "Wageree"
  click_on "Submit"

end