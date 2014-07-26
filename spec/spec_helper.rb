require_relative "./../app"
require "capybara/rspec"
ENV["RACK_ENV"] = "test"

Capybara.app = App

RSpec.configure do |config|
  config.before do
    database_connection = GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])

    database_connection.sql("BEGIN")
  end

  config.after do
    database_connection = GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])

    database_connection.sql("ROLLBACK")
  end
end

def fill_in_registration_form(name)
  visit "/users/new"
  fill_in "Email", with: name
  fill_in "Password", with: name.downcase
  fill_in "Confirm", with: name.downcase
  fill_in "Profile Picture", with: "http://google.com"
  click_on "Submit"
end


def login_a_registered_user(name)
  fill_in "Email", with: name
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
  fill_in "Credit Card Number", with: "123456789"
  fill_in "Exp Date", with: "2014-07-31"
  fill_in "Name on Card", with: "Seth Geyer"
  within(page.find("#new_deposits")) { choose "Visa" }
  click_on "Submit"
end

def distribute_funds_from_my_account(distribution_amount, charity)
  click_on "Distribute Funds"
  fill_in "Amount", with: distribution_amount
  select charity, from: "charity_dd"
  click_on "Submit"
end