class Deposits
  def initialize(db_connection)
    @database_connection = db_connection
  end

  def create_in_dbase(id, amount, cc_number, exp_date, name_on_card, cc_type)
    @database_connection.sql("INSERT INTO deposits (account_id, amount, cc_number, exp_date, name_on_card, cc_type) VALUES (#{id}, #{amount}, #{cc_number}, '#{exp_date}', '#{name_on_card}', '#{cc_type}')")
  end

  def find_most_recent(account_id)
    @database_connection.sql("select * from deposits where account_id=#{account_id} order by id asc").first
  end

#### BUILD A SPEC TEST FOR FIND MOST RECENT

end