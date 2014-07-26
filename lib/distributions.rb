class Distributions
  def initialize(db_connection)
    @database_connection = db_connection
  end

  def create_in_dbase(id, amount, charity)
    @database_connection.sql("INSERT INTO distributions (account_id, amount, charity) VALUES (#{id}, #{amount.to_i * 100}, '#{charity}')")
  end

  def find_most_recent(account_id)
    @database_connection.sql("SELECT * FROM distributions WHERE account_id=#{account_id} ORDER BY id DESC").first
  end

  def sum_by_account_id(account_id)
    @database_connection.sql("SELECT SUM(amount) FROM distributions WHERE account_id=#{account_id} ").first["sum"].to_i / 100
  end

end