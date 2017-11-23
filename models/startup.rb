class Startup < ActiveRecord::Base
  include ModelHelpers

  has_many :investments
  has_many :key_employees
  has_and_belongs_to_many :keywords
  has_many :exit_stragies
  belongs_to :founding_structure
  belongs_to :location

  def self.search(term)
    where(*build_query_args(["name", "url", "description", "tagline", "sector",
                             "industry"], '%'+term.downcase+'%'))
  end

  def investors
    investments.map(&:entity)
  end

  def employees
    key_employees.map(&:entity)
  end
end
