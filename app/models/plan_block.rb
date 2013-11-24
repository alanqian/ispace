class PlanBlock < Struct.new(:id, :name, :color,
                       :width, :height, :depth,
                       :fixture_item_id, :layer, :seq_num,
                       :width_units, :height_units, :depth_units,
                       :facing, :run, :rank, :leading_gap, :trail_gap,
                       :count, :percentage, :spercent)
  def self.by_attr(product, attr, position)
    pos_params = [
      :fixture_item_id, :layer, :seq_num,
      :width_units, :height_units, :depth_units,
      :facing, :run, :rank].map { |f| position.send(f) }
    params = attr.values_at(:id, :name, :color) .
          concat(product.values_at(:width, :height, :depth)).
          concat(pos_params)
    block = self.new(*params)
    block.height *= position.height_units
    block.depth *= position.depth_units
    block.leading_gap = position.leading_gap + position.leading_divider
    block.trail_gap = position.trail_divider
    block.width = block.width * position.width_units +
      position.middle_divider * (position.width_units - 1) +
      block.leading_gap + block.trail_gap
    block
  end

  def self.by_product(product, position)
    pos_params = [
      :fixture_item_id, :layer, :seq_num,
      :width_units, :height_units, :depth_units,
      :facing, :run, :rank].map { |f| position.send(f) }
    params = product.values_at(:code, # :id
                               :name, :color,
                               :width, :height, :depth).concat(pos_params)
    block = self.new(*params)
    block.leading_gap = position.leading_gap + position.leading_divider
    block.trail_gap = position.trail_divider
    block
  end

  def checker
    "□"
  end
end
