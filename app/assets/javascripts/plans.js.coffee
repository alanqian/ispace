# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class Toolbar
  delegates: null

  # delegate object must have a handle(id, el) function
  addDelegate: (obj) ->
    if obj?
      @delegates.push obj

  send: (cmdId) ->
    $("##{cmdId}").click()

  handle: (id, el) ->
    for delegate in @delegates
      break if delegate.handle(id, el)

  init: (button_sel, select_sel) ->
    self = @
    @delegates = []
    $(button_sel).each (index, el) ->
      buttonOpt =
        disable: false
        text: false
        label: el.text
        icons:
          primary: $(el).data("icon")
          secondary: $(el).data("icon2")
      $(el).button(buttonOpt).click (e)->
        #console.log "click it:", this.id
        self.handle(this.id, this)
      return true
    $(select_sel).each (index, el) ->
      $(el).addClass("ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only")
      $(el).change (e) ->
        #console.log "change it", e, this, this.value
        self.handle(this.id, this)
    return self

class PlanEditor
  slotMap: {}     # slot => [ul, space]
  positionMap: {} # position id => position
  productMap: {}  # product_id => position_id, code, name, :price_zone, height, width, depth
  debug: true
  editVersion: 0 # for plan layout editor
  savedVersion: 0 # for plan layout editor
  liIndex: 0
  activeSlotUL: null
  selectedItems: [] # [li, position_id]

  layout_fields: [
    "product_id",
    "fixture_item_id",
    "layer",
    "run",
    "seq_num",
    "init_facing",
    "facing",
    "height_units",
    "width_units",
    "depth_units", ]

  handlers: {}

  log: () ->
    if @debug
      console.log.apply(console, arguments)

  # handle toolbar commands
  handle: (id, el) ->
    self = @
    fn = @handlers[id]
    if fn
      console.log "handle", id, el
      fn(el)
      return true
    else
      return false

  init: ()->
    @selectedItems = []
    @activeSlotUL = null
    @editVersion = 0
    @savedVersion = 0
    @initSlotMap()
    @productMap = $("#products-data").data("meta")
    slotPosition = @loadPosition()
    @initSlotItems(slotPosition)
    @initHandler()
    @log "planEditor inited"
    return @

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

    $("#plan-layout-form").submit (e) ->
      self.storePosition()

    $(window).unload () ->
      self.save()

    # to install auto-save timer
    @save()

    # initialize command handler
    @handlers =
      #"plan-new":           () -> self.onPlanNew()
      "plan-save":           () -> self.onPlanSave()
      "plan-switch-model-store":(el) -> self.onPlanSwitchModelStore(el.value)
      "plan-edit-summary":  () -> self.onPlanEditSummary()
      "plan-publish":       () -> self.onPlanPublish()     #
      "plan-copy-to":       () -> self.onPlanCopyTo()      # dup the plan to other model stores
      "position-facing-inc":() -> self.onPositionFacingInc()
      "position-facing-dec":() -> self.onPositionFacingDec()
      "position-remove":    () -> self.onPositionRemove()
      "positions-reorder":  () -> self.onPositionsReorder()
                          # Products can be repositioned in a different order
                          # within a shelf or from a combination of shelves.
                          # Select the products in the order that you want them to appear on
                          # the shelf. (The first product selected will be first in traffic flow).
      "position-edit-leading-gaps": () -> self.onPositionEditLeadingGaps()  # ?: show dialog
      "position-edit-dividers":     () -> self.onPositionEditDividers()  # ?: show dialog

      "switch-product-information": () -> self.onSwitchProductInformation(), # switch the info on right/bottom/hide
      "sort": () -> console.log ""
      "select-showing-information": () -> console.log "", # product infobox or product list on bottom
      "switch-show-colors":         () -> console.log ""  # (brand/manufacture/product/supplier)

  initSlotMap: () ->
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
        my: "left top"
        at: "left top"
        of: target
        collision: "none"

      # save the ul to slot map
      self.log el
      fixture_item = ul.data("fixture-item")
      layer = ul.data("layer")
      space = ul.data("space")
      for f in ["merch_width", "merch_height", "merch_depth", "shelf_height", "from_base"]
        space[f] = parseFloat(space[f])
      space.free = space.merch_width
      self.slotMap[self.slotKey(fixture_item, layer)] = [ul, space]
      true

    # create jquery sortable
    sortableOpt =
      connectWith: ".sortable-container"
      remove: (e, ui) ->
        # e.target: removed from slot ul
        self.removeItemFromSlot(ui.item, e.target)
      receive: (e, ui)->
        # ui.item.parent() => received ul
        # remove is the constract
        self.addItemToSlot(ui.item, ui.item.parent().get(0))
      update: (e, ui) ->
        # when update, mark it selected and dirty
        # console.log "update!"
        self.selectSlotItem(ui.item.get(0), false)
        self.setDirty()
      # stop: (e, ui) ->
      #   console.log "stop!"
      # over: (e, ui) ->
        # e.target: over slot ul
        # console.log "over:", ui.item, e.target
    $("ul.sortable-editor").sortable(sortableOpt).disableSelection()

  isDirty: () ->
    @editVersion > @savedVersion

  showModified: (modified) ->
    text = if modified then "*" else ""
    $("#layout-modified").text(text)

  setDirty: () ->
    oldState = (@savedVersion != @editVersion)
    @editVersion++
    newState = (@savedVersion != @editVersion)
    if oldState != newState
      @showModified(newState)

  setSaved: (version) ->
    oldState = (@savedVersion != @editVersion)
    @savedVersion = version
    newState = (@savedVersion != @editVersion)
    if oldState != newState
      @showModified(newState)

  slotKey: (fixture_item, layer) ->
    if fixture_item >= 0 && layer >= 0
      "#{fixture_item}_#{layer}"
    else
      "?"

  getSlot: (fixture_item, layer) ->
    @slotMap[@slotKey(fixture_item, layer)]

  getULSpace: (ul) ->
    @slotMap[@slotKey($(ul).data("fixture-item"), $(ul).data("layer"))][1]

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
    for slot, item of @slotMap
      ul = item[0]
      ul.empty() # remove all LIs at first
      positions = slotPosition[slot] # [position_id, seq_num, ..]
      # add items if exists
      if positions
        positions.sort (a, b) ->
          (a.seq_num - b.seq_num) <= 0
        for position in positions
          @newSlotItem(position, ul)
    @setSaved(@editVersion)

  newSlotItem: (position, ul) ->
    li = $("<li id='pos_#{@liIndex++}' class='sortable-item' data-id='#{position.id}'></li>").appendTo(ul)
    # set default position for new item to slot
    product_id = position.product_id
    product = @productMap[product_id]
    if position.facing <= 0 || position.height_units <= 0 || position.width_units <= 0
      space = @getULSpace(ul)
      position.height_units = Math.floor(space.merch_height / product.height)
      position.facing = position.init_facing
      position.width_units = position.init_facing
      position.depth_units = Math.floor(space.merch_depth / product.depth)
    # always recalc run
    position.recalcRun(product)
    @addItemToSlot(li, ul)

  addItemToSlot: (li, ul) ->
    # 1. set place info for position: fixture-item/layer
    # 2. recalulate slot free space
    # 3  if slot is overflowed now or is overflowed before, then
    #      update all items in slot, include his one;
    #    else
    #      update this item only
    position_id = $(li).data("id")
    position = @positionMap[position_id]
    position.setPlace($(ul).data("fixture-item"), $(ul).data("layer"), 0)
    @updateSlotSpace(ul, -position.run, $(li), position)

  removeItemFromSlot: (li, ul) ->
    # 1. unset place info for position: fixture-item/layer
    # 2.+3. very like above addItemToSlot work flow
    position_id = $(li).data("id")
    position = @positionMap[position_id]
    position.setPlace(-1, -1, -1)
    @updateSlotSpace(ul, position.run, null, null)

  updateSlotSpace: (ul, delta, li, position) ->
    @setDirty()
    self = @
    slotKey = @slotKey($(ul).data("fixture-item"), $(ul).data("layer"))
    space = @slotMap[slotKey][1]
    old_free_space = space.free
    space.free += delta

    if old_free_space > 0 && space.free <= 0
      $(ul).removeClass("sortable-container")
    else if old_free_space <= 0 && space.free > 0
      $(ul).addClass("sortable-container")

    if space.free > 0
      $("div.space-overflow", ul.parentNode).hide()
    else
      overflow = ((space.merch_width - space.free) * 100.0) / space.merch_width
      $("div.space-overflow", ul.parentNode).text("#{overflow.toFixed(0)}%").show().position
        of: ul
        collision: "none"

    @log "free space updated:", ul, delta, old_free_space, space.free
    if old_free_space < 0 || space.free < 0
      # update all items in slot
      $("li", ul).each (index, el) ->
        position_id = $(el).data("id")
        self.updateSlotItemView $(el), self.positionMap[position_id], ul
        true
    else if position != null # removed item
      # update the changed item only
      @updateSlotItemView(li, position, ul)

  # update item view: height,width/title/grids/align_bottom
  updateSlotItemView: (li, position, ul) ->
    # create a rows x cols table in LI
    rows = position.height_units
    cols = position.width_units
    tds = Array(cols+1).join("<td></td>")
    trs = Array(rows+1).join("<tr>#{tds}</tr>")
    table = "<table><tbody>#{trs}</tbody></table>"
    li.html(table)

    # update title of LI
    product = @productMap[position.product_id]
    title = "#{product.name} #{product.price_zone}"
    li.attr("title", title)

    # calculate height/width of LI
    slotKey = position.slotKey()
    space = @slotMap[slotKey][1]
    virtual_width = if space.free >= 0 then space.merch_width else (space.merch_width - space.free)
    height = position.height_units * product.height * $(ul).height() / space.merch_height
    width = position.run * $(ul).width() / virtual_width - 2
    li.css("width", "#{width}px")
    li.css("height", "#{height}px")

    # align LI to bottom of $(ul)
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

  # load initial positions from form/input
  loadPosition: () ->
    self = @
    console.log "init position"
    @positionMap = {}
    slotPosition = {}
    $("#plan-layout-form input[name^='plan[positions_attributes]['][name$='[id]']").each (index,el) ->
      prefix = el.id.replace(/_id$/, "")
      id = el.value
      position =
        id: id
        run: 0
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
        slotKey: () ->
          self.slotKey(this.fixture_item_id, this.layer)

        recalcRun: (product) ->
          # TODO: add precious version for calculate run
          this.run = product.width * this.facing

      for f in self.layout_fields
        if f == "product_id"
          position[f] = $("##{prefix}_#{f}").val() || "?"
        else
          position[f] = parseInt($("##{prefix}_#{f}").val()) || -1

      # add to positionMap
      self.positionMap[el.value] = position

      # mark position to product
      product_id = position.product_id
      self.productMap[product_id] ||= {}
      self.productMap[product_id]["position_id"] = id

      # save position to slotPosition
      slot = position.slotKey()
      slotPosition[slot] ||= []
      slotPosition[slot].push position
      true
    return slotPosition

  # store positions to form/inputs
  storePosition: () ->
    # update fixture_item/layer/seq_num for each position object
    # by order of slot items
    self = @
    # store edit version
    $("#plan_layout_version").val(@editVersion)
    for slot,item of @slotMap
      ul = item[0]
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

  newPosition: (product_id) ->
    position_id = @productMap[product_id]
    position = @positionMap[position_id]
    if position.isOnShelf()
      @log "new position ignored, already on shelf", product_id, position
    else if @activeSlotUL == null
      @log "new position ignored, no active slot", product_id
    else
      @log "new position added", product_id, @activeSlotUL
      @newSlotItem(position, @activeSlotUL)

  save: () ->
    return console.log "save"

    if @isDirty()
      console.log "submit!"
      $("#plan-layout-form").submit()

    self = @
    saveProc = () ->
      self.save()
    setTimeout(saveProc, 90000)  # 90s

  onPlanSave: () ->
    $("#plan-layout-form").submit()

  onPlanSwitchModelStore: (store_id) ->
    # /plans/13/edit?_do=layout
    re = new RegExp("/plans/\\d+/edit")
    href = window.location.href.replace(re, "/plans/#{store_id}/edit")
    #console.log "jump to", store_id, href
    window.location.replace(href)

  onPlanEditSummary: () ->

  onPlanPublish: () ->

  onPlanCopyTo: () ->      # dup the plan to other model stores

  onPositionRemove: () ->
    if @selectedItems.length == 0
      console.log "no selected items"
    for item in @selectedItems
      el = item[0]
      @removeItemFromSlot(el, el.parentNode)
      $(el).remove() # remove LI element
    @selectedItems = []

  onPositionFacingInc: () ->
    item = @getActiveSlotItem()
    if item != null
      position_id = item[1]
      position = @positionMap[position_id]
      @changePositionFacing(position, 1)

  onPositionFacingDec: () ->
    item = @getActiveSlotItem()
    if item != null
      position_id = item[1]
      position = @positionMap[position_id]
      if position.facing == 1
        @onPositionRemove()
      else
        @changePositionFacing(position, -1)

  changePositionFacing: (position, delta) ->
    product = @productMap[position.product_id]
    old_run = position.recalcRun(product)
    position.facing += delta
    position.width_units += delta
    new_run = position.recalcRun(product)
    slotKey = position.slotKey()
    slotUL = @slotMap[slotKey][0]
    li = $("li.sortable-item[data-id='#{position.id}']")
    @updateSlotSpace(slotUL, old_run - new_run, li, position)

$ ->
  window.planEditor = new PlanEditor
  window.planEditor.init()

  window.myToolbar = new Toolbar
  window.myToolbar.init(".toolbar-button", ".toolbar-select").addDelegate(window.planEditor)
  return true

  #############################################
  # following is test code

  # position it
  $("#test").position({my: "left top", at: "left top", of: $("#back"), collision: "none"})

  $("div.ui-resizable").resizable()
  $("div.ui-draggable").draggable()

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
