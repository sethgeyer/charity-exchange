describe Mvps do

  let(:database_connection) { GschoolDatabaseConnection::DatabaseConnection.establish("test") }
  let(:mvps) { Mvps.new(database_connection)}

  describe "#find_all" do
    it "returns a list of all mvps" do
      database_connection.sql("INSERT INTO mvps (date, description) VALUES ('2014-07-01', 'this is my most recent post')")
      mvps.find_all
      search_results = database_connection.sql("SELECT * from mvps")
      expect(search_results.size).to eq(1)
    end
  end

  describe "#add_to_dbase" do
    it "adds the mvp to the dbase" do
      mvps.add_to_dbase("2014-07-01", "This is my 1st MVP")
      search_results = database_connection.sql("SELECT * from mvps")
      expect(search_results.size).to eq(1)
      expect(search_results[0]["description"]).to eq("This is my 1st MVP")
    end
  end

end