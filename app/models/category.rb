class Category < ActiveRecord::Base
  self.primary_key = "name"
  validates :name, presence: true
  validates :name, uniqueness: true
  before_destroy :ensure_not_referenced

  def self.default_id
    self.all().first.id
  end

  private
  def ensure_not_referenced
    # TODO: add reference check
  end
end
