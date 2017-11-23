class Entity < ActiveRecord::Base
  include ModelHelpers

  has_many :investments
  has_many :key_employees
  has_many :social_entity_lookups
  belongs_to :location

  self.inheritance_column = :classname

  def self.find_user(provider, url)
    where("data -> ? = ?", "socials-#{provider}", url)
  end

  def self.search(term)
    where(*build_query_args(["name", "url", "description"],
                            '%'+term.downcase+'%'))
  end

  def all_incarnations
    Entity.where(:url => url)
  end

  def any_image_url
    all_incarnations.map(&:image_url).compact.first
  end
end

class Employee < Entity
end

class Investor < Entity
end
