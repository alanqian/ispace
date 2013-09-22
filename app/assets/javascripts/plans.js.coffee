# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class PlanEditor
  @slotMap: {}     # slot => ul
  @positionMap: {} # position id => position
  @productMap: {}  # product_id => position_id, code, name, :price_zone, height, width, depth
  @debug: true
  @dirtyFlag: false # for plan layout editor
  @liIndex: 0
  @activeSlotUL: null
  @selectedItems: [] # [li, position_id]

  layout_fields: [
    "product_id",
    "fixture_item_id",
    "layer",
    "seq_num",
    "init_facing",
    "facing",
    "height_units",
    "width_units",
    "depth_units", ]

  log: () ->
    if @debug
      console.log.apply(console, arguments)

  init: ()->
    @selectedItems = []
    @activeSlotUL = null
    @initSlot()
    @productMap = $("#products-data").data("meta")
    slotPosition = @initPosition()
    @initSlotItems(slotPosition)
    @initHandler()
    @log "inited"

  initHandler: () ->
    console.log "init handlers"
    self = @

    # init set active slot handler
    $("ul.sortable-editor").click (e) ->
      self.setActiveSlot(this)

    $("ul.sortable-editor li").click (e) ->
      self.selectSlotItem(this, e.ctrlKey)
      self.setActiveSlot(this.parentElement, e.ctrlKey && self.selectedItems.length > 1)
      e.stopPropagation()

    $("div.bay-layer.bay-shelf").click (e) ->
      ul = $(this).prev().find("ul.sortable-editor")[0]
      self.setActiveSlot(ul)

  initSlot: () ->
    console.log "build slots"
    # init slotMap
    self = @
    @slotMap = {}
    @activeSlotUL = null
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

  setActiveSlot: (el, addSelectItem=false) ->
    # when in addSelectItem mode, don't change exist activeSlot
    if (!addSelectItem || @activeSlotUL == null)
      if @activeSlotUL != el
        # deactivate the old active UL
        $("ul.sortable-editor.ui-selected").removeClass("ui-selected")

        # activate the new active UL
        $(el).addClass("ui-selected")
        @activeSlotUL = el

  initSlotItems: (slotPosition) ->
    console.log "init slot items"
    self = @
    @liIndex = 0
    for slot, ul of @slotMap
      ul.empty() # remove all LIs at first
      items = slotPosition[slot] # [position_id, seq_num, ..]
      # add items if exists
      if items
        items.sort (a, b) ->
          (a.seq_num - b.seq_num) <= 0
        for item in items
          self.addSlotItem(item[0], ul)

  addSlotItem: (position_id, ul) ->
    # create merchandise items(LI), put it to proper slots
    # <li id="pos_0" class="sortable-item"
    #   title="" # by product id
    #   data-id="#{position_id}">
    #   <table>..</table>
    # </li>
    # create LI element
    $("<li id='pos_#{@liIndex++}' class='sortable-item' data-id='#{position_id}'></li>").appendTo(ul)
    @resetSlotItem(position_id, ul)

  resetSlotItem: (position_id, ul) ->
    li = $("li.sortable-item[data-id='#{position_id}']")
    ul ||= li.parent()
    @calcDefaultPosition(position_id, ul)

    position = @positionMap[position_id]
    product = @productMap[position.product_id]
    title = "#{product.name} #{product.price_zone}"
    li.attr("title", title)

    space_width = $(ul).data("width")
    width = position.run * ul.width() / space_width

    space = $(ul).data("space")
    height = position.height_units * product.height * ul.height() / space.merch_height

    li.css("width", "#{width}px")
    li.css("height", "#{height}px")

    # create a rows x cols table in LI
    rows = position.height_units || 1
    cols = position.width_units || 1
    tds = Array(cols+1).join("<td></td>")
    trs = Array(rows+1).join("<tr>#{tds}</tr>")
    table = "<table><tbody>#{trs}</tbody></table>"
    li.html(table)

    # align LI to bottom of UL
    total = $(ul).height()
    h = li.outerHeight()
    li.css("margin-top", (total - h) + "px")

  selectSlotItem: (el, addMode) ->
    if !addMode
      for item in @selectedItems
        $(item[0]).removeClass("ui-selected")
      @selectedItems = []
    @selectedItems.push [el, $(el).data("id")]
    $(el).addClass("ui-selected")

  getActiveSlotItem: () ->
    if @selectedItems.length == 1
      @selectedItems[0]
    else
      null

  initPosition: () ->
    self = @
    console.log "init position"
    @positionMap = {}
    slotPosition = {}
    $("#plan-layout-form input[name^='plan[positions_attributes]['][name$='[id]']").each (index,el) ->
      prefix = el.id.replace(/_id$/, "")
      id = el.value
      position =
        id: id
        input_id: (f)->
          "##{prefix}_#{f}"
        isOnShelf: () ->
          this.fixture_item_id > 0 && this.layer > 0 && this.seq_num >= 0
        offShelf: () ->
          this.fixture_item_id = -1
          this.layer = -1
          this.seq_num = -1
          this.facing = 0
          this.width_units = 0
        setPlace: (fixture_item_id, layer, seq_num) ->
          this.fixture_item_id = fixture_item_id
          this.layer = layer
          this.seq_num = seq_num
        recalcRun: (product) ->
          # TODO: add precious version for calculate run
          this.run = product.width * this.facing

      for f in self.layout_fields
        if f == "product_id"
          position[f] = $("##{prefix}_#{f}").val() || "?"
        else
          position[f] = parseInt($("##{prefix}_#{f}").val()) || -1

      self.positionMap[el.value] = position

      # mark product
      product_id = position.product_id
      self.productMap[product_id] ||= {}
      self.productMap[product_id]["position_id"] = id

      # save position to slotPosition
      fixture_item_id = position.fixture_item_id
      layer = position.layer
      seq_num = position.seq_num
      slot = self.slotKey(fixture_item_id, layer)
      slotPosition[slot] ||= []
      slotPosition[slot].push [id, seq_num, el]
      true
    return slotPosition

  newPosition: (product_id) ->
    position_id = @productMap[product_id]
    position = @positionMap[position_id]
    if position.isOnShelf()
      @log "new position ignored, already on shelf", product_id, position
    else if @activeSlotUL == null
      @log "new position ignored, no active slot", product_id
    else
      @log "new position ignored", product_id, @activeSlotUL
      @calcDefaultPosition(positon_id, @activeSlotUL)
      @addSlotItem(position_id, @activeSlotUL)
      @setDirty(true)

  calcDefaultPosition: (position_id, ul) ->
    position = @positionMap[position_id]
    product_id = position.product_id
    product = @productMap[product_id]
    space = $(ul).data("space")
    position.height_units = Math.floor(space.merch_height / product.height)
    position.facing = position.init_facing
    position.width_units = position.init_facing
    position.depth_units = Math.floor(space.merch_depth / product.depth)
    position.recalcRun(product)

  # store positions to form inputs
  storePosition: () ->
    # update fixture_item/layer/seq_num for each position object
    # by order of slot items
    self = @
    for slot,ul of @slotMap
      fixture_item = ul.data("fixture-item")
      layer = ul.data("layer")
      console.log slot, ul
      console.log fixture_item, layer
      seq_num = 1
      $("li", ul).each (index, el) ->
        position_id = $(el).data("id")
        self.log "setPlace", position_id, fixture_item, layer, seq_num
        self.positionMap[position_id].setPlace(fixture_item, layer, seq_num++)
        true

    # store positions to form INPUTs
    for position_id, position of @positionMap
      for f in @layout_fields
        $(position.input_id(f)).val(position[f])
    return true

  removePosition: () ->
    if @selectedItems.length == 0
      console.log "no selected items"
    for item in @selectedItems
      # remove li
      el = item[0]
      $(el).remove()
      # update position data
      position_id = item[1]
      @positionMap[position_id].offShelf()
      @setDirty(true)
    @selectedItems = []

  positionIncFacing: () ->
    item = @getActiveSlotItem()
    if item != null
      position_id = item[1]
      position = @positionMap[position_id]
      position.facing++
      position.width_units++
      resetSlotItem(position_id)

  positionDecFacing: () ->
    item = @getActiveSlotItem()
    if item != null
      position_id = item[1]
      position = @positionMap[position_id]
      if position.facing == 1
        @removePosition(position_id)
      else
        position.facing--
        position.width_units--
        resetSlotItem(position_id)

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

