class Fixture < ActiveRecord::Base
  has_many :fixture_items, -> { order(:item_index) }, dependent: :destroy
  accepts_nested_attributes_for :fixture_items, allow_destroy: true

  def deep_copy(uid)
    # copy self
    new_fixture = self.dup # shallow copy
    new_fixture.name += "(copy)"
    new_fixture.user_id = user_id
    new_fixture.save!

    # copy associations
    copy_assoc_to(new_fixture, :fixture_items)

    new_fixture
  end

  def deploy_to(store_id, category_id)
    StoreFixture.create({
      fixture_id: self.id,
      store_id: store_id,
      category_id: category_id,
      code: "fixture-code",
    })
  end

  # <UL> continuous space: layer
  #   [fixture_item:layer, bay_id:run:num_bays:space_height:shelf_height:shelf_color, ...]
  # base:
  #   [ fixture_item, bay_id:run:num_bays:base_height:base_color]
  def shelf_spaces
    spaces = {}
    fixture_items.each do |fi|
      # add base
      bay = fi.bay
      spaces[fi.id] = {
        fixture_item: fi.id,
        num_bays: fi.num_bays,
        continuous: fi.continuous,
        bay_id: bay.id,
        base_width: bay.base_width,
        base_height: bay.base_height,
        base_color: bay.base_color,
        num_layers: bay.elem_count,
        height: bay.back_height,
        width: bay.back_width,
      }

      # add each layer
      # [fixture_item:layer, bay_id:run:num_bays:space_height:shelf_height:shelf_color, ...]
      from_base = 0
      height = 0
      1.upto(bay.elem_count) do |layer|
        elem = bay.get_element(layer)
        if elem
          spaces[fi.id][layer] = {
            merch_width: elem.merch_width * fi.num_bays,
            merch_depth: elem.merch_depth,
            merch_height: elem.merch_height,
            shelf_height: elem.shelf_thick,
            from_base: elem.from_base,
            shelf_color: elem.color
          }
          if elem.from_base > from_base
            from_base = elem.from_base
            height = bay.base_height + elem.from_base + elem.shelf_thick + elem.merch_height
          end
        end
      end
      spaces[fi.id][:height] = height
    end
    return spaces
  end

  # returns layer-key => fixture_item_id, layer, merch_space
  def merch_spaces
    merch_space = Struct.new(:fixture_item, :layer, :merch_width, :merch_height, :merch_depth,
                             :used_space, :from_base, :count)
    run = {}
    spaces = []
    fixture_items.each do |fi|
      spaces.concat(fi.bay.layers.map { |layer|
        merch_space.new(fi.id, layer.level,
                        layer.merch_width * fi.num_bays, layer.merch_height, layer.merch_depth,
                        0, layer.from_base, 0) })
    end
    # convert to hash
    {}.tap { |h| spaces.each {|sp| h[Position.layer_key(sp.fixture_item, sp.layer)] = sp } }
  end

  private
  def copy_assoc_to(new_fixture, assoc_sym)
    self.send(assoc_sym).each do |row|
      new_row = row.dup # shallow copy
      new_fixture.send(assoc_sym) << new_row
    end
  end
end
