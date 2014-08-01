# require "active_record"

class ProposedWager < ActiveRecord::Base
  belongs_to :account

end