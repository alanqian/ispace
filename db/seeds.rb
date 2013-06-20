# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Category.delete_all
Category.create(id: '牙膏',
                desc: %{各种品类的牙膏，含特种牙膏})
Category.create(id: '饮料',
                desc: %{可乐、纯净水、矿泉水等})

