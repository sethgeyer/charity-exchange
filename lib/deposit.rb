class Deposit
  def initialize(db_connection)
    @database_connection = db_connection
  end

  def create_in_dbase(id, amount, cc_number, exp_date, name_on_card, cc_type)
    @database_connection.sql("INSERT INTO deposits (account_id, amount, cc_number, exp_date, name_on_card, cc_type) VALUES (#{id}, #{amount.to_i * 100}, #{cc_number}, '#{exp_date}', '#{name_on_card}', '#{cc_type}')")
  end

  def find_most_recent(account_id)
    find_by_account_id(account_id).first
  end

  def sum_by_account_id(account_id)
    @database_connection.sql("SELECT SUM(amount) FROM deposits WHERE account_id=#{account_id} ").first["sum"].to_i / 100
  end

  def find_by_account_id(account_id)
    @database_connection.sql("SELECT * FROM deposits WHERE account_id=#{account_id} ORDER BY id DESC")
  end

end