#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

imports = ["category", "store", "product", "sale"]

imports.each do |t|
  klass = "import_#{t}".classify.constantize
  importor = klass.new(store_id: 1, user_id: 1)
  importor.import_local("../#{t}.xls")
end

stores = Store.all().first(2)
Store.define_model_store(stores)
stores = Store.all().last(2)
Store.define_model_store(stores)

