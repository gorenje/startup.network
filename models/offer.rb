class Offer < ActiveRecord::Base
  belongs_to :investment
  belongs_to :entity
  belongs_to :user

  self.inheritance_column = :classname
end

class BidToBuy < Offer
end

class OfferToSell < Offer
end
