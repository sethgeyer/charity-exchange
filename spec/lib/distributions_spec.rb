describe Distributions do

  let(:database_connection) { GschoolDatabaseConnection::DatabaseConnection.establish("test") }
  let(:distributions) { Distributions.new(database_connection)}

  before(:each) do
    database_connection.sql("INSERT INTO users (email, password, id) VALUES ('sgeyer@gmail.com', 'sethy', 5)")
    database_connection.sql("INSERT INTO accounts (amount, user_id, id) VALUES (10, 5, 1)")
    expect(database_connection.sql("SELECT COUNT(*) FROM distributions").first["count"].to_i).to eq(0)
  end

  describe "#create_in_dbase" do
    it "triggers the creation of a distribution in the dbase" do
      distributions.create_in_dbase(1, 200, "United Way") #id, amount, charity
      distribution = database_connection.sql("SELECT * from distributions").first
      expect(distribution["account_id"]).to eq("1")
      expect(distribution["amount"]).to eq("20000")
      expect(distribution["charity"]).to eq("United Way")
    end
  end

  describe "#find_most_recent" do
    it "finds the most recent distribution" do
      database_connection.sql("INSERT INTO distributions (id, account_id, amount, charity) VALUES (7, 1, 300, 'United Way')")
      database_connection.sql("INSERT INTO distributions (id, account_id, amount, charity) VALUES (8, 1, 300, 'Red Cross')")
      distribution = distributions.find_most_recent(1)
      expect(distribution["id"]).to eq("8")
    end
  end

  describe "#sum_by_account_id" do
    it "provides a sum total of all distributions by account" do
      database_connection.sql("INSERT INTO distributions (id, account_id, amount, charity) VALUES (7, 1, 30000, 'United Way')")
      database_connection.sql("INSERT INTO distributions (id, account_id, amount, charity) VALUES (8, 1, 40000, 'Red Cross')")
      distribution = distributions.sum_by_account_id(1)
      expect(distribution).to eq(700)
    end
  end

end
