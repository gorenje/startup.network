class KeyEmployee < ActiveRecord::Base
  belongs_to :entity
  belongs_to :startup

  def self.by_role(role_name)
    where("lower(role) like ? or lower(role) = ?", "% #{role_name.downcase}%",
          role_name.downcase)
  end
end
