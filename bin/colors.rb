#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

colors = I18n.t("dict.colors").values
colors.shift # remove black

models = [
  Category,
  Brand,
  Product,
  Supplier,
]

models.each do |klass|
  klass.set_random_colors(colors)
end

Bay.update_all(
  back_color: '#ffffff',
  base_color: '#8b0000'
)
OpenShelf.update_all(
  color: '#dcdcdc'
)
PegBoard.update_all(
  color: '#dcdcdc'
)
FreezerChest.update_all(
  color: '#c0c0c0'
)
RearSupportBar.update_all(
  color: '#ff00ff'
)
__END__

random colors:

0. Category:
   by category_id
1. Brand:
   categroy_id
2.
