class Region < ActiveRecord::Base
  self.primary_key = "code"
  before_save :update_redundancy

  has_many :stores

  def self.parent_id(self_id)
    codes = self_id.split(".")
    codes.pop
    return codes.join(".")
  end

  def self.get_display_name(code)
    ids = [self.parent_id(code), code]
    ar = self.where(code: ids).select("name").order(:code)
    return ar.map { |r| r.name }.join("")
  end

  def update_redundancy
    # display_name
    # pinyin
    self.pinyin = HanziToPinyin.hanzi_to_pinyin(name)
  end
end
