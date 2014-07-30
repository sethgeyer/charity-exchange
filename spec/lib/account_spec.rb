describe Account do

  # let(:database_connection) { GschoolDatabaseConnection::DatabaseConnection.establish("test") }
  # let(:accounts) { Account.new(database_connection)}
  #
  # describe "#create_in_dbase" do
  #   it "triggers the creation of an account for the new user" do
  #     database_connection.sql("INSERT INTO users (email, password) VALUES ('sgeyer@gmail.com', 'sethy')")
  #     expect(database_connection.sql("SELECT COUNT(*) FROM accounts").first["count"].to_i).to eq(0)
  #     id = database_connection.sql("SELECT id from users WHERE email='sgeyer@gmail.com'").first["id"]
  #     accounts.create_in_dbase(id)
  #     account = database_connection.sql("SELECT * from accounts").first
  #     expect(account["user_id"]).to eq(id)
  #   end
  # end
  #
  # describe "#find_by_user_id" do
  #   it "finds the account based on the users id" do
  #     database_connection.sql("INSERT INTO users (email, password, id) VALUES ('sgeyer@gmail.com', 'sethy', 5)")
  #     database_connection.sql("INSERT INTO accounts (amount, user_id) VALUES (10, 5)")
  #     account = accounts.find_by_user_id(5)
  #     expect(account["user_id"]).to eq("5")
  #     expect(account["amount"]).to eq("10")
  #   end
  # end
  #
  # describe "#find_by_id" do
  #   it "finds the account based on the id" do
  #     database_connection.sql("INSERT INTO users (email, password, id) VALUES ('sgeyer@gmail.com', 'sethy', 5)")
  #     database_connection.sql("INSERT INTO accounts (amount, user_id, id) VALUES (10, 5, 1)")
  #     account = accounts.find_by_id(1)
  #     expect(account["user_id"]).to eq("5")
  #     expect(account["amount"]).to eq("10")
  #   end
  # end







end
