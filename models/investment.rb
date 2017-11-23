class Investment < ActiveRecord::Base
  belongs_to :entity
  belongs_to :startup
  has_many :offers
end
