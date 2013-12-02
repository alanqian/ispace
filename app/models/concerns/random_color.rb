module RandomColor
  extend ActiveSupport::Concern

  module ClassMethods
    def set_random_colors(colors)
      options = colors.shuffle
      count = 0
      self.select(:category_id, :id, :color).order(:category_id).each do |brand|
        brand.update_column(:color, options[count % options.size])
        count += 1
      end
      count
    end
  end
end
