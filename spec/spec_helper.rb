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