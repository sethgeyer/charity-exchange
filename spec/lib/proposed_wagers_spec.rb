require 'spec_helper'

describe ProposedWager do

  let(:database_connection) { GschoolDatabaseConnection::DatabaseConnection.establish("test") }
  let(:proposed_wagers) { ProposedWager.new(database_connection) }

  describe "#create_in_dbase" do
    it "creates a proposed_wager record in the database" do
      expect(database_connection.sql("SELECT COUNT(*) FROM proposed_wagers").first["count"].to_i).to eq(0)
      proposed_wagers.create_in_dbase(1, "Ping Pong", "2014-07-31", "Game to 21", 100, 2)
        expect(database_connection.sql("SELECT COUNT(*) FROM proposed_wagers").first["count"].to_i).to eq(1)
        expect(database_connection.sql("SELECT amount FROM proposed_wagers").first["amount"]).to eq("10000")
    end
  end

  describe "#find_all" do
    it "returns all proposed_wagers associated with the user" do
      database_connection.sql("INSERT INTO users (id, email, password) VALUES (1, 'seth@gmail.com', 'seth')")
      database_connection.sql("INSERT INTO users (id, email, password) VALUES (2, 'alex@gmail.com', 'alex')")
      database_connection.sql("INSERT INTO proposed_wagers (user_id, title, date_of_wager, details, amount, wageree_id) VALUES (1, 'Ping Pong', '2014-07-31', 'Game to 21', 10000, 2)")
      database_connection.sql("INSERT INTO proposed_wagers (user_id, title, date_of_wager, details, amount, wageree_id) VALUES (1, 'Ping Pong Rematch', '2014-07-31', 'Game to 21', 20000, 2)")
      wagers = proposed_wagers.find_all(1)
      expect(wagers.size).to eq(2)
    end
  end

end