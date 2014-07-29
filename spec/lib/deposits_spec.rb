describe Deposit do

  let(:database_connection) { GschoolDatabaseConnection::DatabaseConnection.establish("test") }
  let(:deposits) { Deposit.new(database_connection)}

  before(:each) do
    database_connection.sql("INSERT INTO users (email, password, id) VALUES ('sgeyer@gmail.com', 'sethy', 5)")
    database_connection.sql("INSERT INTO accounts (amount, user_id, id) VALUES (10, 5, 1)")
    expect(database_connection.sql("SELECT COUNT(*) FROM deposits").first["count"].to_i).to eq(0)
  end

  describe "#create_in_dbase" do
    it "triggers the creation of a deposit in the dbase" do
      deposits.create_in_dbase(1, 300, 123456789, '2015-07-31', "Seth Geyer", "Visa") #id, amount, cc_number, exp_date, name_on_card, cc_type
      deposit = database_connection.sql("SELECT * from deposits").first
      expect(deposit["account_id"]).to eq("1")
      expect(deposit["amount"]).to eq("30000")
      expect(deposit["exp_date"]).to eq("2015-07-31")
    end
  end

  describe "#find_most_recent" do
    it "finds the most recent deposit" do
      database_connection.sql("INSERT INTO deposits (id, account_id, amount, cc_number, exp_date, name_on_card, cc_type) VALUES (7, 1, 300, 123456789, '2015-07-31', 'Seth Geyer', 'Visa')")
      database_connection.sql("INSERT INTO deposits (id, account_id, amount, cc_number, exp_date, name_on_card, cc_type) VALUES (8, 1, 300, 123456789, '2015-07-31', 'Seth Geyer', 'Visa')")
      deposit = deposits.find_most_recent(1)
      expect(deposit["id"]).to eq("8")
    end
  end

  describe "#sum_by_account_id" do
    it "provides a sum total of all deposits by account" do
      database_connection.sql("INSERT INTO deposits (id, account_id, amount, cc_number, exp_date, name_on_card, cc_type) VALUES (7, 1, 30000, 123456789, '2015-07-31', 'Seth Geyer', 'Visa')")
      database_connection.sql("INSERT INTO deposits (id, account_id, amount, cc_number, exp_date, name_on_card, cc_type) VALUES (8, 1, 40000, 123456789, '2015-08-31', 'Seth Geyer', 'Visa')")
      deposit = deposits.sum_by_account_id(1)
      expect(deposit).to eq(700)
    end
  end

  describe "#find_by_account_id" do
    it "returns an array of all deposits for a particular account" do
      database_connection.sql("INSERT INTO deposits (id, account_id, amount, cc_number, exp_date, name_on_card, cc_type) VALUES (7, 1, 30000, 123456789, '2015-07-31', 'Seth Geyer', 'Visa')")
      database_connection.sql("INSERT INTO deposits (id, account_id, amount, cc_number, exp_date, name_on_card, cc_type) VALUES (8, 1, 40000, 123456789, '2015-08-31', 'Seth Geyer', 'Visa')")
      database_connection.sql("INSERT INTO deposits (id, account_id, amount, cc_number, exp_date, name_on_card, cc_type) VALUES (9, 5, 40000, 123456789, '2015-08-31', 'Seth Geyer', 'Visa')")
      deposit = deposits.find_by_account_id(1)
      expect(deposit.size).to eq(2)
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
