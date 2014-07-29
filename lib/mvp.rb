class Mvp
  def initialize(db_connection)
    @database_connection = db_connection
  end

  def find_all
    @database_connection.sql("SELECT * from mvps ORDER BY date  DESC")
  end

  def add_to_dbase(date, description)
    @database_connection.sql("INSERT INTO mvps (date, description) VALUES ('#{date}', '#{description}')")
  end

end