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

  def self.set_random_colors(colors)
    count = 0
    options = colors.shuffle
    parents = self.where("length(code) <= 4").select(:code, :color)
    parents.each do |ctg|
      ctg.update_column(:color, options[count % options.size])
      count += 1
    end
    parents = self.where("length(code) <= 4")
      .select(:code, :color, :parent_id)
      .to_hash(:code)

    leaves = self.where("length(code) >= 5").order(:code).select(:code, :parent_id, :color)
    opt = count
    leaves.each do |ctg|
      p1 = parents[ctg.parent_id]
      p2 = parents[p1.parent_id]
      while options[opt % options.size] == p1.color ||
        options[opt % options.size] == p2.color
        opt += 1
      end
      ctg.update_column(:color, options[opt % options.size])
      opt += 1
      count += 1
    end
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
