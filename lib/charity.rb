class Charity
  def initialize(db_connection)
    @database_connection = db_connection
  end

  def find_all
    @database_connection.sql("SELECT * from charities")
  end

  def add_to_dbase(name, tax_id, poc, poc_email, status)
    @database_connection.sql("INSERT INTO charities (name, tax_id, poc, poc_email, status) VALUES ('#{name}', #{tax_id}, '#{poc}', '#{poc_email}', '#{status}')")
  end


end