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

Bay.delete_all
OpenShelf.delete_all
PegBoard.delete_all
FreezerChest.delete_all
RearSupportBar.delete_all

# create template open_shelf
OpenShelf.create(
  id: 0,
  bay_id: 0,
  name: "shelf ",
  height: 20.0,
  width: 120.0,
  depth: 50.0,
  thick: 1.0,
  slope: 0.0,
  riser: 0.0,
  notch_num: 0,
  from_base: 1.0,
  color: '#dfdfdf',
  from_back: 0.0,
  finger_space: 0.0,
  x_position: 0.0,
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
  takeoff_height: 0.0,
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
    notch_num: 0,
    from_base: from_base,
    color: '#dfdfdf',
    from_back: 0.0,
    finger_space: 0.0,
    x_position: 0.0,
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
    takeoff_height: 0.0,
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
    notch_num: 0,
    from_base: from_base,
    color: '#dfdfdf',
    from_back: 0.0,
    finger_space: 0.0,
    x_position: 0.0,
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
    takeoff_height: 0.0,
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
    notch_num: 0,
    from_base: from_base,
    color: '#ffffff',
    from_back: 0.0,
    finger_space: 0.0,
    x_position: 0.0,
  )
  level += 1
end

bay = Bay.create(
    name: '60x7层板',
    back_height: 185.0,
    back_width: 60.0,
    back_thick: 3.0,
    back_color: '#400040',
    notch_spacing: 1.0,
    notch_1st: 1.0,
    base_height: 15.0,
    base_width: 60.0,
    base_depth: 50.0,
    base_color: '#400040',
    takeoff_height: 0.0,
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
    notch_num: 0,
    from_base: from_base,
    color: '#dfdfdf',
    from_back: 0.0,
    finger_space: 0.0,
    x_position: 0.0,
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
    takeoff_height: 0.0,
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
  from_base: 4.0,
  color: '#dfdfdf',
  from_back: 0.0,
  finger_space: 0.0,
  x_position: 0.0,
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
  notch_num: 1,
  from_base: 4.0,
  color: '#dfdfdf',
);

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
    takeoff_height: 0.0,
    elem_type: 0,
    elem_count: 4
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
  from_base: 4.0,
  color: '#dfdfdf',
  from_back: 0.0,
  finger_space: 0.0,
  x_position: 0.0,
)
[[30.0, 45.0, 20], [80.0, 0.0, 30], [30, 0.0, 40]].each do |height, from_back, notch_num|
  level += 1
  RearSupportBar.create(
    bay_id: bay.id,
    name: "Bar #{level-1}",
    height: height,
    bar_depth: 4.0,
    bar_thick: 4.0,
    from_back: from_back,
    hook_length: 40.0,
    notch_num: notch_num,
    from_base: (notch_num - 1) * bay.notch_spacing + bay.notch_1st,
    color: '#ff007f',
    bar_slope: 0.0,
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
  takeoff_height: 0.0,
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
    from_base: 0.0,
    color: '#dfdfdf',
    from_back: from_back,
    finger_space: 0.0,
    x_position: 0.0,
  )
end

