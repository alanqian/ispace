# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class PlanEditor
  @slotMap: {}
  @productMap: {}
  @positionMap: {} # position id => position
  @positionList: {} # by slot, slot(fi,layer) => seq_num, position_id
  @productMap: {} # product_id => code, name, :price_level, height, width, depth
  @debug: true
  @dirtyFlag: false # for plan layout editor

  log: () ->
    if @debug
      console.log.apply(console, arguments)

  init: ()->
    @initSlot()
    @initPosition()
    @productMap = $("#products-data").data("meta")
    @initSlotItems()
    @initHandler()

    # create merchandise items(LI), put it to proper slots

    # xxx;
    @log "inited"

  initHandler: () ->
    console.log "init handlers"

  initSlot: () ->
    console.log "build slots"
    # init slotMap
    self = @
    @slotMap = {}
    # init merchandise slots, position it to proper space div
    $("ul.sortable-editor").each (index, el) ->
      ul = $(el)
      # position the slot to its container
      target = ul.data("container")
      ul.width $(target).width() - (ul.outerWidth() - ul.width())
      ul.height $(target).height() - (ul.outerHeight() - ul.height())
      ul.position
        my: "left bottom"
        at: "left bottom"
        of: target
        collision: "none"

      # save the ul to slot map
      self.log el
      fixture_item = ul.data("fixture-item")
      layer = ul.data("layer")
      self.slotMap[self.slotKey(fixture_item, layer)] = ul

    # create jquery sortable
    sortableOpt =
      connectWith: ".sortable-editor"
      receive: (e, ui)->
        # ui.item.parent() => received ul
        # remove is the constract
        console.log "received:", ui.item, ui.item.parent()
      over: (e, ui) ->
        console.log "over:", ui.item, e.target
    $("ul.sortable-editor").sortable(sortableOpt).disableSelection()

  isDirty: () ->
    @dirtyFlag

  setDirty: (dirtyFlag) ->
    @dirtyFlag = dirtyFlag

  slotKey: (fixture_item, layer) ->
    if fixture_item >= 0 && layer >= 0
      "#{fixture_item}_#{layer}"
    else
      "?"

  getSlot: (fixture_item, layer) ->
    @slotMap[@slotKey(fixture_item, layer)]

  initSlotItems: () ->
    console.log "init slot items"

  testGridBottom: () ->
    # create grid for product
    self = @
    $("ul.sortable-editor li").each (index,el) ->
      position_id = $(el).data("id")
      position = self.positionMap[position_id]
      product = self.productMap[product_id]
      rows = position.height_units || 1
      cols = position.width_units || 1
      # create a rows x cols table in LI
      tds = Array(cols+1).join("<td></td>")
      trs = Array(rows+1).join("<tr>#{tds}</tr>")
      table = "<table><tbody>#{trs}</tbody></table>"
      $(el).html(table)

    # align each LI to bottom of UL
    $("ul.sortable-editor").each (index, ul) ->
      total = $(ul).height()
      $(ul).children("li").each (index, li) ->
        h = $(li).outerHeight()
        $(li).css("margin-top", (total - h) + "px")

  initPosition: () ->
    self = @
    console.log "init position"
    @positionMap = {}
    @positionList = {}
    $("#plan-layout-form input[name^='plan[positions_attributes]['][name$='[id]']").each (index,el) ->
      prefix = el.id.replace(/_id$/, "")
      id = el.value
      fixture_item = $("##{prefix}_fixture_item_id").val() || -1
      layer = $("##{prefix}_layer").val() || -1
      seq_num = $("##{prefix}_seq_num").val() || -1
      self.positionMap[el.value] =
        id: id
        el: prefix
        product_id: $("##{prefix}_product_id").val()
        facing: $("##{prefix}_facing").val() || 1
        fixture_item: fixture_item
        layer: layer
        seq_num: seq_num
        init_facing: $("##{prefix}_init_facing").val()
        height_units: $("##{prefix}_height_units").val() || 1
        width_units: $("##{prefix}_width_units").val() || 1
        depth_units: $("##{prefix}_depth_units").val() || 1
      slot = self.slotKey(fixture_item, layer)
      self.positionList[slot] ||= []
      self.positionList[slot].push [id, seq_num, el]

  newPosition: () ->
    console.log "new position"

  removePosition: () ->
    console.log "remove position"

  positionIncFacing: (e) ->
    console.log "inc facing", e

  positionDecFacing: (e) ->
    console.log "dec facing", e

$ ->
  $(".toolbar-button").each (index, el) ->
    btn = $(el).button
      disable: false
      text: false
      label: el.text
      icons:
        primary: $(el).data("icon")
        secondary: $(el).data("icon2")
    btn.click ->
      console.log "click it:", this.id

  window.planEditor = new PlanEditor
  window.planEditor.init()

  # position it
  # $("#test").position({my: "left top", at: "left top", of: $("#back"), collision: "none"})

  return true
  $("div.ui-resizable").resizable()
  $("div.ui-draggable").draggable()

  #############################################
  # following is test code
  sel = $("#select").button
    disabled: false
    text: false
    label: "v"
    icons:
      primary: "ui-icon-triangle-1-s"

  $(".toolbar-button-set").each (index,el) ->
    $(el).buttonset()

  sel.click ->
    menu = $("#menu").show().position
      my: "left top"
      at: "left bottom"
      of: this
    $(document).one "click", ->
      menu.hide()
    return false

  $("#menu").hide().menu()
  #############################################

