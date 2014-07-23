describe Charities do

  let(:database_connection) { GschoolDatabaseConnection::DatabaseConnection.establish("test") }
  let(:charities) { Charities.new(database_connection)}

  describe "#find_all" do
    it "returns a list of all charities" do
      database_connection.sql("INSERT INTO charities (name, tax_id, poc, poc_email, status) VALUES ('United Way', 123456789, 'Steve Smith', 'smith@unitedway.com', 'unregistered')")
      charities.find_all
      search_results = database_connection.sql("SELECT * from charities")
      expect(search_results.size).to eq(1)
    end
  end

  describe "#add_to_dbase" do
    it "adds the charity to the dbase as an unregisterd charity" do
      charities.add_to_dbase("United Way", 123456789, "Steve Smith", "ssmith@gmail.com", "unregistered")
      search_results = database_connection.sql("SELECT * from charities")
      expect(search_results.size).to eq(1)
      expect(search_results[0]["status"]).to eq("unregistered")
    end
  end


end