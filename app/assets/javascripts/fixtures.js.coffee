# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

root = exports ? this

root.test = () ->
  foo()

root.addElement = (template, newId, index, tag) =>
  re = new RegExp(template.data("id"), "g")
  fieldId = newId.toString()
  console.log re, "fieldId:", fieldId
  console.log template, newId, target, index, tag
  src = $(template).html().replace("\\n", "").replace(re, fieldId)
  target = $($(template).data "target")
  if index == -1
    console.log "before all children"
    target.prepend(src)
  else if index == Infinity
    console.log "after all children"
    target.append(src)
  else
    console.log "insert after #{index} #{tag}"
    $(tag, target).eq(index).after(src)
  return target

root.addFixtureItem = (event, el) ->
  console.log "add fixture item, active:", window.fixture.active
  event.preventDefault()

  container = $("#fixture_items")
  active = window.fixture.active
  template = $($(el).data "id")

  if active >= 0
    addElement template, window.fixture.newIndex, active, "tr"
    window.fixture.setActive(active + 1)
  else
    addElement template, window.fixture.newIndex, Infinity, "tr"
    rows = $("td.fixture_item", container).parent().length
    window.fixture.setActive(rows - 1)
  window.fixture.newIndex += 1
  updateControls(false)
  return false

root.removeFixtureItem = (event) ->
  console.log "remove fixture item"
  event.preventDefault()

  active = window.fixture.active
  if active >= 0
    tbody = $("td.fixture_item").closest('tbody')
    tr = tbody.children("tr").eq(active)
    # set conrepond _destroy to 1
    $("input[type=hidden][name$='[_destroy]']", tr).val("1")
    window.fixture.setActive -1
    tr.hide()
  else
    console.log "no active item"
  updateControls(true)
  return false


root.fixtureItemFocus = (event) ->
  el = event.target
  # console.log "focus, val: ", $(el).val()
  tr = $(el).closest("tr")
  index = tr.parent().children("tr").index(tr)
  active = window.fixture.setActive(index)
  console.log "active: ", active

root.updateItemIndex = () ->
  console.log "update Item indice in order"
  els = $("input[type=hidden][name$='[item_index]']", $("#fixture_items"))
  item_index = 0
  els.each (index,el) ->
    destroy = $(el).siblings("input[type=hidden][name$='[_destroy]']")
    # console.log index, el, destroy.get(0)
    if destroy.first().val() == "false"
      $(el).val(item_index)
      item_index += 1

root.updateFixtureMetrics = ->
  window.fixture.run = 0.0
  window.fixture.linear = 0.0
  window.fixture.area = 0.0
  window.fixture.cube = 0.0
  $("#fixture_items").children("tr").each (index, el) ->
    if $("input[type=hidden][name$='[_destroy]']", $(el)).first().val() == "false"
      bay_id = $("[name$='[bay_id]']", $(el)).val()
      num_bays = $("[name$='[num_bays]']", $(el)).val()
      console.log bay_id, num_bays
      bay = window.bays[bay_id]
      if bay
        window.fixture.run += bay.run * num_bays
        window.fixture.linear += bay.linear * num_bays
        window.fixture.area += bay.area * num_bays
        window.fixture.cube += bay.cube * num_bays
  $("#run").html(window.fixture.run)
  $("#linear").html(window.fixture.linear)
  $("#area").html(window.fixture.area)
  $("#cube").html(window.fixture.cube)

root.updateControls = (updateMetricOnly) ->
  if !updateMetricOnly
    container = $("#fixture_items")
    $("td.fixture_item input", container).focus fixtureItemFocus
    $("td.fixture_item select", container).focus fixtureItemFocus
    $("td.fixture_item input", container).change updateFixtureMetrics
    $("td.fixture_item select", container).change updateFixtureMetrics
  updateFixtureMetrics()

$ ->
  console.log "fixture editor start..."
  console.log window.bays[30]

  # move template outside of the form
  $("form").after($("#template"))

  window.fixture = {
    active: -1,
    newIndex: $("td.fixture_item").parent().length + 10,
    setActive: (index) ->
      # deactive the old index, active the new index
      tbody = $("td.fixture_item").closest('tbody')
      if @active != index
        if @active >= 0
          tbody.children("tr").eq(@active).removeClass("active")
        if index >= 0
          tbody.children("tr").eq(index).addClass("active")
        @active = index
      return @active
  }
  updateControls(false)

