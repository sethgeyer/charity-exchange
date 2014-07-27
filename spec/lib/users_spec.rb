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

  describe "#find_user" do
    it "returns the user hash associated with the unique email and address passed" do
      users.create_new_user_in_dbase("sgeyer@gmail.com", "fudge", "http://google.com")
      person = users.find_user("sgeyer@gmail.com", "fudge")
      expect(person["email"]).to eq("sgeyer@gmail.com")
    end
  end

  describe "#find_user_by_id" do
    it "returns the user hash associated with the id passed" do
      users.create_new_user_in_dbase("sgeyer@gmail.com", "fudge", "http://google.com")
      id = database_connection.sql("SELECT id FROM users WHERE email='sgeyer@gmail.com'").first["id"]
      person = users.find_user_by_id(id)
      expect(person["email"]).to eq("sgeyer@gmail.com")
    end
  end

  describe "#update user info" do
    it "updates the users information in the database" do
      users.create_new_user_in_dbase("sgeyer@gmail.com", "fudge", "http://google.com")
      id = database_connection.sql("SELECT id FROM users WHERE email='sgeyer@gmail.com'").first["id"].to_i
      users.update_user_info(id, "nudge", "www.goggle.com")
      person = users.find_user_by_id(id)
      expect(person["password"]).to eq("nudge")
      expect(person["profile_picture"]).to eq("www.goggle.com")
    end
  end

  describe "#all" do
    it "returns all users except for the current user" do
      database_connection.sql("INSERT INTO users (id, email, password) VALUES (1, 'seth@gmail.com', 'seth')")
      database_connection.sql("INSERT INTO users (id, email, password) VALUES (2, 'alex@gmail.com', 'alex')")
      database_connection.sql("INSERT INTO users (id, email, password) VALUES (3, 'bill@gmail.com', 'bill')")
      list_of_users = users.all_but_current_user('1')
      expect(list_of_users.size).to eq(2)
    end
  end




end