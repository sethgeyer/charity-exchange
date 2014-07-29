class ProposedWager
  def initialize(db_connection)
    @database_connection = db_connection
  end

  def create_in_dbase(user_id, title, date_of_wager, details, amount, wageree_id)
    @database_connection.sql("INSERT INTO proposed_wagers (user_id, title, date_of_wager, details, amount, wageree_id) VALUES (#{user_id}, '#{title}', '#{date_of_wager}', '#{details}', #{amount.to_i * 100}, #{wageree_id.to_i})")
  end

  def find_all(user_id)
    @database_connection.sql("SELECT * from proposed_wagers WHERE user_id=#{user_id}")
  end

end