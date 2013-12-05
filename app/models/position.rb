class Position < ActiveRecord::Base
  belongs_to :plan
  belongs_to :product, primary_key: :code
  scope :on_shelf, -> { where("layer >= 0 AND seq_num >= 0") }
  scope :not_on_shelf, -> { where("layer IS NULL OR layer < 0 OR seq_num IS NULL OR seq_num < 0") }

  attr_accessor :rank

  def on_shelf?
    fixture_item_id > 0 && layer >= 0 && seq_num >= 0
  end

  def layer_key
    "#{fixture_item_id}_#{layer}"
  end

  def self.layer_key(fixture_item_id, layer)
    "#{fixture_item_id}_#{layer}"
  end
end
