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


Bay.delete_all
OpenShelf.delete_all
PegBoard.delete_all
FreezerChest.delete_all
RearSupportBar.delete_all

# create template open_shelf
OpenShelf.create(
  bay_id: -1,
  name: "shelf ",
  height: 20.0,
  width: 120.0,
  depth: 50.0,
  thick: 1.0,
  slope: 0.0,
  riser: 0.0,
  notch_num: 1,
  from_base: 1.0,
  color: '#ffffff',
  from_back: 0.0,
  finger_space: 0.0,
  x_position: 0.0,
  level: -1,
)
PegBoard.create(
  bay_id: -1,
  name: "Pegboard ",
  height: 200.0,
  depth: 30.0,
  vert_space: 6.0,
  horz_space: 6.0,
  vert_start: 6.0,
  horz_start: 6.0,
  notch_num: 1,
  from_base: 1.0,
  color: '#dfdfdf',
  level: -1,
)
FreezerChest.create(
  bay_id: -1,
  name: 'Chest',
  height: 90.0,
  depth: 100.0,
  wall_thick: 4.0,
  inside_height: 80.0,
  merch_height: 70.0,
  color: '#ffff',
  level: -1,
)
RearSupportBar.create(
  bay_id: -1,
  name: "Bar ",
  height: 30.0,
  bar_depth: 4.0,
  bar_thick: 4.0,
  from_back: 45.0,
  hook_length: 40.0,
  notch_num: 20,
  from_base: 80.0,
  color: '#ff007f',
  bar_slope: 0.0,
  level: -1,
)


# create Bay '120*7层板',
bay = Bay.create(
  name: '120x7层板',
  back_height: 185.0,
  back_width: 120.0,
  back_thick: 3.0,
  back_color: '#ffffff',
  notch_spacing: 1.0,
  notch_1st: 1.0,
  base_height: 15.0,
  base_width: 120.0,
  base_depth: 50.0,
  base_color: '#400040',
  elem_type: 1,
  elem_count: 7
)

# for notch_num
# from_base = (notch_num - 1) * notch_spacing + notch_first
# UI: when check notch spacing, only need edit notch_num,
#     otherwise, edit from_base;
level = 1
[1.0, 27.0, 53.0, 79.0, 105.0, 131.0, 157.0].each do |from_base|
  OpenShelf.create(
    bay_id: bay.id,
    name: "shelf #{level}",
    height: 20.0,
    width: 120.0,
    depth: 46.0,
    thick: 5.0,
    slope: 0.0,
    riser: 0.0,
    notch_num: bay.to_notch(from_base),
    from_base: from_base,
    color: '#dfdfdf',
    from_back: 0.0,
    finger_space: 0.0,
    x_position: 0.0,
    level: level,
  )
  level += 1
end

# 120x8层板
bay = Bay.create(
    name: '120x8层板',
    back_height: 185.0,
    back_width: 120.0,
    back_thick: 3.0,
    back_color: '#ffffff',
    notch_spacing: 1.0,
    notch_1st: 1.0,
    base_height: 15.0,
    base_width: 120.0,
    base_depth: 50.0,
    base_color: '#400040',
    elem_type: 1,
    elem_count: 8
)

level = 1
[1.0, 23.0, 45.0, 67.0, 89.0, 111.0, 133.0, 155.0].each do |from_base|
  OpenShelf.create(
    bay_id: bay.id,
    name: "shelf #{level}",
    height: 20.0,
    width: 120.0,
    depth: 50.0,
    thick: 1.0,
    slope: 0.0,
    riser: 0.0,
    notch_num: bay.to_notch(from_base),
    from_base: from_base,
    color: '#dfdfdf',
    from_back: 0.0,
    finger_space: 0.0,
    x_position: 0.0,
    level: level
  )
  level += 1
end

bay = Bay.create(
    name: '60x8层板',
    back_height: 185.0,
    back_width: 60.0,
    back_thick: 3.0,
    back_color: '#ffffff',
    notch_spacing: 1.0,
    notch_1st: 1.0,
    base_height: 15.0,
    base_width: 60.0,
    base_depth: 50.0,
    base_color: '#400040',
    elem_type: 1,
    elem_count: 8
)
level = 1
[1.0, 23.0, 45.0, 67.0, 89.0, 111.0, 133.0, 155.0].each do |from_base|
  OpenShelf.create(
    bay_id: bay.id,
    name: "shelf #{level}",
    height: 20.0,
    width: 60.0,
    depth: 50.0,
    thick: 1.0,
    slope: 0.0,
    riser: 0.0,
    notch_num: bay.to_notch(from_base),
    from_base: from_base,
    color: '#ffffff',
    from_back: 0.0,
    finger_space: 0.0,
    x_position: 0.0,
    level: level
  )
  level += 1
end

bay = Bay.create(
    name: '60x7层板',
    back_height: 185.0,
    back_width: 60.0,
    back_thick: 3.0,
    back_color: '#ffffff',
    notch_spacing: 1.0,
    notch_1st: 1.0,
    base_height: 15.0,
    base_width: 60.0,
    base_depth: 50.0,
    base_color: '#400040',
    elem_type: 1,
    elem_count: 7
)
level = 1
[1.0, 27.0, 53.0, 79.0, 105.0, 131.0, 157.0].each do |from_base|
  OpenShelf.create(
    bay_id: bay.id,
    name: "shelf #{level}",
    height: 20.0,
    width: 60.0,
    depth: 48.0,
    thick: 5.0,
    slope: 0.0,
    riser: 0.0,
    notch_num: bay.to_notch(from_base),
    from_base: from_base,
    color: '#dfdfdf',
    from_back: 0.0,
    finger_space: 0.0,
    x_position: 0.0,
    level: level,
  )
  level += 1
end

# peg board
bay = Bay.create(
    name: 'Peg board',
    back_height: 200.0,
    back_width: 133.0,
    back_thick: 4.0,
    back_color: '#ffffff',
    notch_spacing:  4.0,
    notch_1st: 4.0,
    base_height: 10.0,
    base_width: 120.0,
    base_depth: 40.0,
    base_color: '#101010',
    elem_type: 0,
    elem_count: 2
)
level = 1
OpenShelf.create(
  bay_id: bay.id,
  name: "shelf #{level}",
  height: 30.0,
  width: 133.0,
  depth: 60.0,
  thick: 4.0,
  slope: 0.0,
  riser: 0.0,
  notch_num: 1,
  from_base: bay.notch_to(1),
  color: '#dfdfdf',
  from_back: 0.0,
  finger_space: 0.0,
  x_position: 0.0,
  level: level
)
level += 1
# ???: some errors in peg board
PegBoard.create(
  bay_id: bay.id,
  name: "Pegboard #{level}",
  height: 200.0,
  depth: 30.0,
  vert_space: 6.0,
  horz_space: 6.0,
  vert_start: 6.0,
  horz_start: 6.0,
  notch_num: 9,
  from_base: bay.notch_to(9),
  color: '#dfdfdf',
  level: level,
)

# hanging bars
bay = Bay.create(
  name: 'Hanging bars',
  back_height: 200.0,
  back_width: 133.0,
  back_thick: 4.0,
  back_color: '#ffffff',
  notch_spacing: 4.0,
  notch_1st: 4.0,
  base_height: 10.0,
  base_width: 120.0,
  base_depth: 40.0,
  base_color: '#101010',
  elem_type: 0,
  elem_count: 4,
)
level = 1
OpenShelf.create(
  bay_id: bay.id,
  name: "shelf #{level}",
  height: 30.0,
  width: 133.0,
  depth: 60.0,
  thick: 4.0,
  slope: 0.0,
  riser: 0.0,
  notch_num: 1,
  from_base: bay.notch_to(1),
  color: '#dfdfdf',
  from_back: 0.0,
  finger_space: 0.0,
  x_position: 0.0,
  level: level,
)
[[30.0, 45.0, 20], [80.0, 0.0, 30], [30, 0.0, 40]].each do |height, from_back, notch_num|
  level += 1
  RearSupportBar.create(
    bay_id: bay.id,
    name: "Bar #{level}",
    height: height,
    bar_depth: 4.0,
    bar_thick: 4.0,
    from_back: from_back,
    hook_length: 40.0,
    notch_num: notch_num,
    from_base: bay.notch_to(notch_num),
    color: '#ff007f',
    bar_slope: 0.0,
    level: level,
  )
end

# create Bay 'Freezer with shelves',
bay = Bay.create(
  name: 'Freezer with shelves',
  back_height: 200.0,
  back_width: 133.0,
  back_thick: 4.0,
  back_color: '#ffffff',
  notch_spacing: 4.0,
  notch_1st: 4.0,
  base_height: 10.0,
  base_width: 120.0,
  base_depth: 40.0,
  base_color: '#101010',
  elem_type: 0,
  elem_count: 3
)
FreezerChest.create(
  bay_id: bay.id,
  name: 'Chest',
  height: 90.0,
  depth: 100.0,
  wall_thick: 4.0,
  inside_height: 80.0,
  merch_height: 70.0,
  color: '#ffff',
  level: 1,
)
[[1, 31, 48.0], [2, 43, 0.0]].each do |level, notch_num, from_back|
  OpenShelf.create(
    bay_id: bay.id,
    name: "shelf #{level}",
    height: 30.0,
    width: 133.0,
    depth: 50.0,
    thick: 4.0,
    slope: 30.0,
    riser: 10.0,
    notch_num: notch_num,
    from_base: bay.notch_to(notch_num),
    color: '#dfdfdf',
    from_back: from_back,
    finger_space: 0.0,
    x_position: 0.0,
    level: level,
  )
end

#####################################################################
# fixtrue data
Fixture.delete_all
FixtureItem.delete_all

fixtures = []
["120x8层板货架", "5组120层板货架", "4组120层板货架", "3组120层板+1组60层板货架"].each do |name|
  fixtures.push Fixture.create(
    name: name,
    code: name[0..4],
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
  store_id: store.id
  role: 'salesman'
)
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

