# require "active_record"

class Account < ActiveRecord::Base
  belongs_to :user
  has_many :deposits
  has_many :distributions
  has_many :proposed_wagers


end