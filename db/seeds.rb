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

# create Bay '120*7层板',
bay = Bay.create(
    name: '120*7层板',
    back_height: 185.0,
    back_width: 120.0,
    back_thick: 3.0,
    back_color: '#ffffff',
    notch_spacing:  0.0,
    notch_1st: 0.0,
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
level=1
[1.0, 27.0, 53.0, 79.0, 105.0, 131.0, 157.0].each do |from_base|
  OpenShelf.create(
    bay_id: bay.id,
    level: level,
    name: "shelf #{level}",
    height: 20.0,
    width: 120.0,
    depth: 46.0,
    thick: 5.0,
    slope: 0.0,
    riser: 0.0,
    from_base: from_base,
    color: '#dfdfdf',
    from_back: 0.0,
    finger_space: 0.0,
    x_positon: 0.0,
  )
  level += 1
end

