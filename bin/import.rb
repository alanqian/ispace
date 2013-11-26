#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

imports = {
  "product" => {
    #files: "商品档案1.csv",
    files: "尺寸.csv",
    klass: Brand,
  },
  "sale" => "",
  "category" => {
    files: "分类.xlsx",
  },
  "store" => {
    files: "便利店基础信息.xlsx",
    klass: Region,
  },
  #"product" => ["商品档案1.xlsx",
  #  "商品档案2.xlsx",
  #  "商品档案3.xlsx",
  #  "商品档案4.xlsx",
  #  "商品档案5.xlsx",
  #  "商品档案6.xlsx",
  #  "商品档案7.xlsx",
  #  "商品档案8.xlsx"],
}

#Region.delete_all
#Brand.delete_all
imports.each do |t, import|
  break if import.empty?

  # normalize to array
  files = [*import[:files]]
  extra_klass = import[:klass]

  model_klass = t.classify.constantize
  model_klass.delete_all
  extra_klass.delete_all if extra_klass

  record_count = lambda do | |
    counter = "#{model_klass.to_s}:#{model_klass.count}"
    counter += " #{extra_klass.to_s}:#{extra_klass.count}" if extra_klass
    counter
  end

  files.each do |file|
    puts "importing #{t}, #{record_count[]}..."
    klass = "import_#{t}".classify.constantize
    importor = klass.new(store_id: 0, user_id: 0)
    importor.import_local("../data/#{file}")
    count = model_klass.count
    puts "#{t} imported, #{record_count[]}..."
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
