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


end