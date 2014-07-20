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
  fill_in "Email", with: name
  fill_in "Password", with: name.downcase
  fill_in "Confirm", with: name.downcase
  fill_in "Profile Picture", with: "http://google.com"
  click_on "Submit"
end