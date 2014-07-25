describe Deposits do

  let(:database_connection) { GschoolDatabaseConnection::DatabaseConnection.establish("test") }
  let(:deposits) { Deposits.new(database_connection)}

  describe "#create_in_dbase" do
    it "triggers the creation of a deposit in the dbase" do
      database_connection.sql("INSERT INTO users (email, password, id) VALUES ('sgeyer@gmail.com', 'sethy', 5)")
      database_connection.sql("INSERT INTO accounts (amount, user_id, id) VALUES (10, 5, 1)")
      expect(database_connection.sql("SELECT COUNT(*) FROM deposits").first["count"].to_i).to eq(0)
      deposits.create_in_dbase(1)
      deposit = database_connection.sql("SELECT * from deposits").first
      #expect(account["user_id"]).to eq(id)
    end
  end

  # describe "#find_by_id" do
  #   xit "finds the account based on the id" do
  #     database_connection.sql("INSERT INTO users (email, password, id) VALUES ('sgeyer@gmail.com', 'sethy', 5)")
  #     database_connection.sql("INSERT INTO accounts (amount, user_id, id) VALUES (10, 5, 1)")
  #     account = accounts.find_by_id(1)
  #     expect(account["user_id"]).to eq("5")
  #     expect(account["amount"]).to eq("10")
  #   end
  # end

end
