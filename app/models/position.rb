class Position < ActiveRecord::Base
  belongs_to :plan
  belongs_to :product

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

  def rank
    @rank
  end

  def rank=(rank)
    @rank = rank
  end
end
