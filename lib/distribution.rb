# require "active_record"

class Distribution < ActiveRecord::Base
  belongs_to :account
  belongs_to :charity


end