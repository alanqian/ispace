class Category < ActiveRecord::Base
  self.primary_key = "code"
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
  before_destroy :ensure_not_referenced
  before_save :update_redundancy

  def self.default_id
    first = self.where("length(code) > 4").first
    if first
      first.id
    else
      "categories-is-empty!"
    end
  end

  def self.tree
    self.all.order(:code).select(:code, :parent_id, :name)
  end

  def self.nodes
    self.where("length(code) >= 5").order(:code).select(:code, :parent_id)
  end

  def upper_code
    self.code[0..code.length-2]
  end

  def self.upper_code(code)
    code[0..code.length-2]
  end

  #TODO: validate parent_id
  # validates_associated :parent_id, if: "code.length<3"

  private
  def ensure_not_referenced
    # TODO: add reference check
  end

  def update_redundancy
    # parent_id
    if self.parent_id && self.parent_id.empty?
      self.parent_id = nil
    end
    # ???: display_name
    # pinyin
    self.pinyin = HanziToPinyin.hanzi_to_pinyin(name)
  end
end
