require 'spec_helper'

describe Users do

  let(:database_connection) { GschoolDatabaseConnection::DatabaseConnection.establish("test") }
  let(:users) { Users.new(database_connection) }

  describe "#create_new_user_in_dbase" do
    it "creates a user record in the database" do
      expect(database_connection.sql("SELECT COUNT(*) FROM users").first["count"].to_i).to eq(0)
      users.create_new_user_in_dbase("sgeyer@gmail.com", "fudge", "http://google.com")
      expect(database_connection.sql("SELECT COUNT(*) FROM users").first["count"].to_i).to eq(1)
    end
  end

  describe "find_by_email" do
    it "returns the user hash associated with the unique email name passed" do
      users.create_new_user_in_dbase("sgeyer@gmail.com", "fudge", "http://google.com")
      person = users.find_by_email("sgeyer@gmail.com")
      expect(person["email"]).to eq("sgeyer@gmail.com")
    end
  end

end