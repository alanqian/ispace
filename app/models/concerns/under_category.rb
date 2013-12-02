module UnderCategory
  extend ActiveSupport::Concern
  attr_accessor :category_name

  def category_name
    self.category.nil? ? "" : self.category.name
  end

  def under(category_id)
    where(["category_id >= ? AND category_id < ?",
          category_id, category_id.succ]).order(:category_id)
  end

  module ClassMethods

    def under(category_id)
      self.where(["category_id >= ? AND category_id < ?",
                 category_id, category_id.succ]).order(:category_id)
    end
  end
end
