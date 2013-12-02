#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

colors = I18n.t("dict.colors").values

models = [
  Brand,
  Supplier,
]

models.each do |klass|
  klass.set_random_colors(colors)
end

__END__


random colors:

0. Category:
   by category_id
1. Brand:
   categroy_id
2.
