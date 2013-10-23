class Category < ActiveRecord::Base
  self.primary_key = "code"
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
  before_destroy :ensure_not_referenced
  before_save :update_redundancy

  def self.default_id
    first = self.all().first
    if first
      first.id
    else
      "categories-is-empty!"
    end
  end

  #TODO: validate parent_id
  # validates_associated :parent_id, if: "code.length<3"

  private
  def ensure_not_referenced
    # TODO: add reference check
  end

  def update_redundancy
    # display_name
    # pinyin
    self.pinyin = HanziToPinyin.hanzi_to_pinyin(name)
  end
end
