class Category < ActiveRecord::Base
  self.primary_key = 'id'
  validates :id, presence: true
  validates :id, uniqueness: true
  before_destroy :ensure_not_referenced

  private
  def ensure_not_referenced
    # TODO: add reference check
  end
end
