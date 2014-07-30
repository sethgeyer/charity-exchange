require "active_record"

class Account < ActiveRecord::Base
  belongs_to :user
  has_many :deposits
  has_many :distributions
  # def initialize(db_connection)
  #   @database_connection = db_connection
  # end

  def create_in_dbase(id)
    @database_connection.sql("INSERT INTO accounts (amount, user_id) VALUES (0, #{id})")
  end

  def find_by_user_id(id)
    @database_connection.sql("SELECT * from accounts WHERE user_id=#{id}").first
  end

  def find_by_id(id)
    @database_connection.sql("SELECT * from accounts WHERE id=#{id}").first
  end



end