# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


#####################################################################
# bay data

require 'csv'

Bay.delete_all
OpenShelf.delete_all
PegBoard.delete_all
FreezerChest.delete_all
RearSupportBar.delete_all

# create Bay '120*7层板',
bay = Bay.create(
  name: '120x7层板',
  back_height: 1850,
  back_width: 1200,
  back_thick: 30,
  back_color: '#ffffff',
  notch_spacing: 10,
  notch_1st: 10,
  base_height: 150,
  base_width: 1200,
  base_depth: 500,
  base_color: '#400040'
)

# for notch_num
# from_base = (notch_num - 1) * notch_spacing + notch_first
# UI: when check notch spacing, only need edit notch_num,
#     otherwise, edit from_base;
level = 1
[100, 270, 530, 790, 1050, 1310, 1570].each do |from_base|
  OpenShelf.create(
    bay_id: bay.id,
    name: "#{level}.隔板",
    height: 200,
    width: 1200,
    depth: 460,
    thick: 50,
    slope: 0,
    riser: 0,
    notch_num: bay.to_notch(from_base),
    from_base: from_base,
    color: '#dfdfdf',
    from_back: 0,
    finger_space: 0,
    x_position: 0,
    level: level,
  )
  level += 1
end

# 120x8层板
bay = Bay.create(
    name: '120x8层板',
    back_height: 1850,
    back_width: 1200,
    back_thick: 30,
    back_color: '#ffffff',
    notch_spacing: 10,
    notch_1st: 10,
    base_height: 150,
    base_width: 1200,
    base_depth: 500,
    base_color: '#400040'
)

level = 1
[100, 230, 450, 670, 890, 1110, 1330, 1550].each do |from_base|
  OpenShelf.create(
    bay_id: bay.id,
    name: "#{level}.隔板",
    height: 200,
    width: 1200,
    depth: 500,
    thick: 30,
    slope: 0,
    riser: 0,
    notch_num: bay.to_notch(from_base),
    from_base: from_base,
    color: '#dfdfdf',
    from_back: 0,
    finger_space: 0,
    x_position: 0,
    level: level
  )
  level += 1
end

bay = Bay.create(
    name: '60x8层板',
    back_height: 1850,
    back_width: 600,
    back_thick: 30,
    back_color: '#ffffff',
    notch_spacing: 10,
    notch_1st: 10,
    base_height: 150,
    base_width: 600,
    base_depth: 500,
    base_color: '#400040'
)
level = 1
[100, 230, 450, 670, 890, 1110, 1330, 1550].each do |from_base|
  OpenShelf.create(
    bay_id: bay.id,
    name: "#{level}.隔板",
    height: 200,
    width: 600,
    depth: 500,
    thick: 30,
    slope: 0,
    riser: 0,
    notch_num: bay.to_notch(from_base),
    from_base: from_base,
    color: '#ffffff',
    from_back: 0,
    finger_space: 0,
    x_position: 0,
    level: level
  )
  level += 1
end

bay = Bay.create(
    name: '60x7层板',
    back_height: 1850,
    back_width: 600,
    back_thick: 30,
    back_color: '#ffffff',
    notch_spacing: 10,
    notch_1st: 10,
    base_height: 150,
    base_width: 600,
    base_depth: 500,
    base_color: '#400040'
)
level = 1
[100, 270, 530, 790, 1050, 1310, 1570].each do |from_base|
  OpenShelf.create(
    bay_id: bay.id,
    name: "#{level}.隔板",
    height: 200,
    width: 600,
    depth: 480,
    thick: 50,
    slope: 0,
    riser: 0,
    notch_num: bay.to_notch(from_base),
    from_base: from_base,
    color: '#dfdfdf',
    from_back: 0,
    finger_space: 0,
    x_position: 0,
    level: level,
  )
  level += 1
end

# peg board
bay = Bay.create(
    name: '钉板+133板',
    back_height: 2000,
    back_width: 1330,
    back_thick: 40,
    back_color: '#ffffff',
    notch_spacing:  40,
    notch_1st: 40,
    base_height: 100,
    base_width: 1200,
    base_depth: 400,
    base_color: '#101010'
)
level = 1
OpenShelf.create(
  bay_id: bay.id,
  name: "#{level}.隔板",
  height: 300,
  width: 1330,
  depth: 600,
  thick: 40,
  slope: 0,
  riser: 0,
  notch_num: 1,
  from_base: bay.notch_to(1),
  color: '#dfdfdf',
  from_back: 0,
  finger_space: 0,
  x_position: 0,
  level: level
)
level += 1
# ???: some errors in peg board
PegBoard.create(
  bay_id: bay.id,
  name: "#{level}.钉板",
  height: 2000,
  depth: 300,
  vert_space: 60,
  horz_space: 60,
  vert_start: 60,
  horz_start: 60,
  notch_num: 50,
  from_base: bay.notch_to(50),
  color: '#dfdfdf',
  level: level,
)

# hanging bars
bay = Bay.create(
  name: '133挂条',
  back_height: 2000,
  back_width: 1330,
  back_thick: 40,
  back_color: '#ffffff',
  notch_spacing: 40,
  notch_1st: 40,
  base_height: 100,
  base_width: 1200,
  base_depth: 400,
  base_color: '#101010'
)
level = 1
OpenShelf.create(
  bay_id: bay.id,
  name: "#{level}.隔板",
  height: 300,
  width: 1330,
  depth: 600,
  thick: 40,
  slope: 0,
  riser: 0,
  notch_num: 1,
  from_base: bay.notch_to(1),
  color: '#dfdfdf',
  from_back: 0,
  finger_space: 0,
  x_position: 0,
  level: level,
)
[[300, 450, 20], [800, 0, 30], [30, 0, 40]].each do |height, from_back, notch_num|
  level += 1
  RearSupportBar.create(
    bay_id: bay.id,
    name: "#{level}.后支撑条",
    height: height,
    bar_depth: 40,
    bar_thick: 40,
    from_back: from_back,
    hook_length: 400,
    notch_num: notch_num,
    from_base: bay.notch_to(notch_num),
    color: '#ff007f',
    bar_slope: 0,
    level: level,
  )
end

# create Bay 'Freezer with shelves',
bay = Bay.create(
  name: '133板+冷藏柜',
  back_height: 2000,
  back_width: 1330,
  back_thick: 40,
  back_color: '#ffffff',
  notch_spacing: 40,
  notch_1st: 40,
  base_height: 100,
  base_width: 1200,
  base_depth: 400,
  base_color: '#101010'
)
FreezerChest.create(
  bay_id: bay.id,
  name: '冷藏柜',
  height: 900,
  depth: 1000,
  wall_thick: 40,
  inside_height: 800,
  merch_height: 700,
  color: '#ffff',
  level: 1,
)
[[1, 31, 4800], [2, 43, 0]].each do |level, notch_num, from_back|
  OpenShelf.create(
    bay_id: bay.id,
    name: "shelf #{level}",
    height: 300,
    width: 1330,
    depth: 500,
    thick: 40,
    slope: 300,
    riser: 100,
    notch_num: notch_num,
    from_base: bay.notch_to(notch_num),
    color: '#dfdfdf',
    from_back: from_back,
    finger_space: 0,
    x_position: 0,
    level: level,
  )
end

# to update metrics of each bay
Bay.all.each do |bay|
  bay.save!
end

#####################################################################
# fixtrue data
Fixture.delete_all
FixtureItem.delete_all

fixtures = []
["120x8层板货架", "5组120层板货架", "4组120层板货架", "3组120层板+1组60层板货架"].each do |name|
  fixtures.push Fixture.create(
    name: name,
    user_id: 0,
    flow_l2r: true,
  )
end

# 120x7层板
# 120x8层板
# 60x8层板
# 60x7层板
bays = Bay.all.first(4)

# "120x8层板货架"
fixture_item = FixtureItem.create(
  fixture_id: fixtures[0].id,
  bay_id: bays[1].id,
  num_bays: 1,
  item_index: 0,
  continuous: true,
)
# "5组120层板货架"
fixture_item = FixtureItem.create(
  fixture_id: fixtures[1].id,
  bay_id: bays[0].id,
  num_bays: 5,
  item_index: 0,
  continuous: true,
)
# "4组120层板货架"
fixture_item = FixtureItem.create(
  fixture_id: fixtures[2].id,
  bay_id: bays[0].id,
  num_bays: 4,
  item_index: 0,
  continuous: true,
)
# "3组120层板+1组60层板货架"
fixture_item = FixtureItem.create(
  fixture_id: fixtures[3].id,
  bay_id: bays[0].id,
  num_bays: 3,
  item_index: 0,
  continuous: true,
)
fixture_item = FixtureItem.create(
  fixture_id: fixtures[3].id,
  bay_id: bays[3].id,
  num_bays: 1,
  item_index: 1,
  continuous: true,
)

__END__

def import_from_csv(table)
  CSV.foreach("db/csvs/#{table}.csv", headers: true) do |row|
    table.singularize.capitalize.constantize.create! row.to_hash
  end
end

Store.delete_all
import_from_csv('stores')

Category.delete_all
import_from_csv('categories')

Product.delete_all
import_from_csv('products')

Sale.delete_all
import_from_csv('sales')

#####################################################################
# basic admin data

User.delete_all
User.create(
  email: 't@g.cn',
  password: '00000000',
  password_confirmation: '00000000',
  username: 'test',
  role: 'admin'
)
User.create(
  email: 'admin@g.cn',
  password: '00000000',
  password_confirmation: '00000000',
  username: '管理员',
  role: 'admin'
)
User.create(
  email: 'd@g.cn',
  password: '00000000',
  password_confirmation: '00000000',
  username: '王二',
  role: 'designer'
)
store = Store.where(name: '郑州1号店').first
User.create(
  email: 's@g.cn',
  password: '00000000',
  password_confirmation: '00000000',
  username: '李大力',
  store_id: store.id,
  role: 'salesman'
)

Category.delete_all
Category.create(
  code: "1",
  name: '百货',
  memo: %{百货})

Category.create(
  code: "101",
  parent_id: "1",
  name: '日用百货',
  memo: %{日用品})

Category.create(
  code: '10101',
  parent_id: "101",
  name: '牙膏',
  memo: %{各种品类的牙膏，含特种牙膏})

Category.create(
  code: '10102',
  parent_id: "101",
  name: '纸巾',
  memo: '')

Region.delete_all
Store.delete_all

Region.create(code: "cn",
              name: "中国",
              consume_type: "B",
              memo: "中国总部")

Region.create(code: "cn.north",
              name: "华北区",
              consume_type: "B",
              memo: "华北区，含内蒙")

Region.create(code: "cn.north.bj",
              name: "北京",
              consume_type: "A+",
              memo: "北京，含各郊县")

Store.create(region_id: "cn.north.bj",
             name: "12号店",
             code: "001",
             area: 60,
             location: "市区",
             memo: "牡丹园，tel: 81231234")
Store.create(region_id: "cn.north.bj",
             name: "18号店",
             code: "002",
             area: 120,
             location: "市区",
             memo: "亚运村，tel: 81231234")

__END__


__END__
Category.delete_all
Category.create(
  code: "1",
  name: '百货',
  memo: %{百货})

Category.create(
  code: "101",
  parent_id: "1",
  name: '日用百货',
  memo: %{日用品})

Category.create(
  code: '10101',
  parent_id: "101",
  name: '牙膏',
  memo: %{各种品类的牙膏，含特种牙膏})

Category.create(
  code: '10102',
  parent_id: "101",
  name: '纸巾',
  memo: '')

Region.delete_all
Store.delete_all

Region.create(code: "cn",
              name: "中国",
              consume_type: "B",
              memo: "中国总部")

Region.create(code: "cn.north",
              name: "华北区",
              consume_type: "B",
              memo: "华北区，含内蒙")

Region.create(code: "cn.north.bj",
              name: "北京",
              consume_type: "A+",
              memo: "北京，含各郊县")

Store.create(region_id: "cn.north.bj",
             name: "12号店",
             code: "001",
             area: 60,
             location: "市区",
             memo: "牡丹园，tel: 81231234")
Store.create(region_id: "cn.north.bj",
             name: "18号店",
             code: "002",
             area: 120,
             location: "市区",
             memo: "亚运村，tel: 81231234")

__END__

