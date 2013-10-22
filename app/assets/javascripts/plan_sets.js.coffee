root = exports ? this

root.onSelectCategory = (el) ->
  id = $(el).data("id")
  name = $(el).text()
  $("#plan_set_category_name").val(name)
  $("#plan_set_category_id").val(id)
  return true

$ ->
  menu = root.cmdUI.createMenu "select-category", $("#plan_set_category_name").data("source"),
    id: "code"
    parent: "parent_id"
    label: "name"
    rootId: null
    dom: "#test-menu"
  root.cmdUI.popupMenuSelect menu,
    right: "#plan_set_category_name"

