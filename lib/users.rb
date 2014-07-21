class Users
  def initialize(db_connection)
    @database_connection = db_connection
  end

  def create_new_user_in_dbase(email, password, profile_picture)
    @database_connection.sql("INSERT INTO users (email, password, profile_picture) VALUES ('#{email}', '#{password}', '#{profile_picture}')")
  end

  def find_user(address, password)
    @database_connection.sql("SELECT * FROM users WHERE email ='#{address}' AND password='#{password}'").first
  end

  def find_user_by_id(id)
    @database_connection.sql("SELECT * FROM users WHERE id =#{id.to_i}").first
  end

  def update_user_info(id, password, profile_picture)
    @database_connection.sql("UPDATE users SET password='#{password}', profile_picture='#{profile_picture}' WHERE id=#{id}")
  end


end