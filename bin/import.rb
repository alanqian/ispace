#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

imports = {
  "category" => "分类.xlsx",
  "store" => "便利店基础信息.xlsx",
  "product" => ["商品档案1.xlsx",
    "商品档案2.xlsx",
    "商品档案3.xlsx",
    "商品档案4.xlsx",
    "商品档案5.xlsx",
    "商品档案6.xlsx",
    "商品档案7.xlsx",
    "商品档案8.xlsx"],
  "sale" => "",
}

Region.delete_all
Brand.delete_all
imports.each do |t, files|
  break if files.empty?

  unless files.is_a?(Array)
    files = [files]
  end

  model_klass = t.classify.constantize
  model_klass.delete_all

  files.each do |file|
    puts "importing #{t}, record count:#{model_klass.count}..."
    klass = "import_#{t}".classify.constantize
    importor = klass.new(store_id: 0, user_id: 0)
    importor.import_local("../data/#{file}")
    count = model_klass.count
    puts "#{t} imported, record count:#{model_klass.count}..."
  end
end

[Category, Region, Store, Brand, Product].each do |model|
  puts "#{model.to_s}: #{model.count}"
end

__END__

#stores = Store.all().first(2)
#Store.define_model_store(stores)
#stores = Store.all().last(2)
#Store.define_model_store(stores)
