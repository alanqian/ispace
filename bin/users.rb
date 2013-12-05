#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

User.delete_all
User.create(
  email: 'admin@g.cn',
  password: '00000000',
  password_confirmation: '00000000',
  username: '管理员',
  role: 'admin'
)

1.upto(9) do |n|
  User.create(
    email: "d#{n}@g.cn",
    password: '00000000',
    password_confirmation: '00000000',
    username: "00#{n}",
    role: 'designer'
  )
end

# create default user for each store
Store.all.each do |store|
  User.create(
    email: "#{store.code}@g.cn",
    password: '88888888',
    password_confirmation: '88888888',
    username: "#{store.code}",
    role: 'salesman'
  )
end

