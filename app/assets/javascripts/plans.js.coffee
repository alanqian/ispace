# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Delegate command UI for
# 1. toolbar: ".toolbar-button", "toolbar-select"
# 2. popup-menu: "ul.pupop-menu"
class CmdUI
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

  init: () ->
    self = @
    @delegates = []
    $(".toolbar-button").each (index, el) ->
      buttonOpt =
        disable: false
        text: false
        label: el.text
        icons:
          primary: $(el).data("icon")
          secondary: $(el).data("icon2")
      $(el).button(buttonOpt).click (e)->
        #console.log "click it:", this.id
        e.stopPropagation()
        self.handle(this.id, this)
      return true

    $(".toolbar-select").each (index, el) ->
      $(el).addClass("ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only")
      $(el).change (e) ->
        #console.log "change it", e, this, this.value
        self.handle(this.id, this)

    # initialize the popup menu width
    menuItemPadding = 28
    $("ul.popup-menu").each (index, ul) ->
      # initialize each popup item
      $(ul).data("maxChild", 0)
      $("li ul", ul).each (index, el) ->
        $(el).data "maxChild", 0

      $("li a", ul).each (index, el) ->
        popup = $(el).closest("ul")
        maxChild = popup.data("maxChild")
        if maxChild < $(el).width()
          popup.data("maxChild", $(el).width())

      # set the width of all popups
      $("li ul", ul).each (index, el) ->
        $(el).width($(el).data("maxChild") + menuItemPadding)
      $(ul).width($(ul).data("maxChild")+ menuItemPadding)

    $("ul.popup-menu").menu().hide()
    $("ul.popup-menu").find("a").click (e) ->
      e.preventDefault()
      e.stopPropagation()
      # hide the outer popup menubox
      $(this).closest("ul.popup-menu").hide()
      self.handle(this.id, this)
    return self

class PlanEditor
  slotMap: {}     # slot => [ul, space]
  positionMap: {} # position id => position
  productMap: {}  # product_id => position_id, code, name, :price_zone, height, width, depth
  showingColor: "color" # product color
  debug: true
  editVersion: 0 # for plan layout editor
  savedVersion: 0 # for plan layout editor
  liIndex: 0
  activeSlotUL: null
  selectedItems: [] # [li, position_id]

  layout_fields:
    product_id: "?"
    fixture_item_id: -1
    layer: -1
    seq_num: -1
    run: 0
    init_facing: 1
    facing: 1
    height_units: 1
    width_units: 1
    depth_units: 1
    leading_gap: 0
    leading_divider: 0
    middle_divider: 0
    trail_divider: 0

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
    @initProductMap()
    @initSlotMap()
    slotPosition = @loadPosition()
    @initSlotItems(slotPosition)
    @initHandler()
    @initModified()
    @log "planEditor inited"
    return @

  initHandler: () ->
    console.log "init handlers"
    self = @

    # init set active slot handler
    $("ul.sortable-editor").click (e) ->
      self.selectSlotItem(null, false)
      self.setActiveSlot(this)

    $("ul.sortable-editor li").click (e) ->
      self.selectSlotItem(this, e.ctrlKey)
      self.setActiveSlot(this.parentElement, e.ctrlKey && self.selectedItems.length > 1)
      e.stopPropagation()

    $("div.bay-layer.bay-shelf").click (e) ->
      ul = $(this).prev().find("ul.sortable-editor")[0]
      self.selectSlotItem(null, false)
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
      "switch-show-colors":         (el) -> self.onSelectShowingColors(el)
      "show-brand-color":           () -> self.onSwitchToColor("brand_color")
      "show-product-color":         () -> self.onSwitchToColor("color")
      "show-manufacturer-color":    () -> self.onSwitchToColor("mfr_color")
      "show-supplier-color":        () -> self.onSwitchToColor("supplier_color")

  initProductMap: () ->
    @productMap = $("#products-data").data("products")
    brands = $("#products-data").data("brands")
    mfrs = $("#products-data").data("mfrs")
    suppliers = $("#products-data").data("suppliers")
    for id,product of @productMap
      product.color ||= "#CC0000"
      product.brand_color = suppliers[product.brand_id] || "#CCCC00"
      product.mfr_color = mfrs[product.mfr_id] || "#CC00CC"
      product.supplier_color = suppliers[product.supplier_id] || "#00CCCC"

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
      # self.log el
      fixture_item = ul.data("fixture-item")
      layer = ul.data("layer")
      space = ul.data("space")
      for f in ["merch_width", "merch_height", "merch_depth", "shelf_height", "from_base"]
        space[f] = parseFloat(space[f])
      space.free = space.merch_width
      space.ul = ul
      self.slotMap[self.slotKey(fixture_item, layer)] = space
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
      start: (e, ui) ->
        self.selectSlotItem(ui.item.get(0), false)
      update: (e, ui) ->
        # when update, mark it selected and dirty
        # console.log "update!"
        self.setDirty()
      # stop: (e, ui) ->
      #   console.log "stop!"
      # over: (e, ui) ->
        # e.target: over slot ul
        # console.log "over:", ui.item, e.target
    $("ul.sortable-editor").sortable(sortableOpt).disableSelection()

  isDirty: () ->
    @editVersion > @savedVersion

  initModified: () ->
    # insert a SPAN to switch model store's default OPTION
    $("#plan-switch-model-store option[selected]").prepend("<span id='layout-modified'></span>")

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
    @slotMap[@slotKey($(ul).data("fixture-item"), $(ul).data("layer"))]

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
      ul = item.ul
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

  dumpSlot: (ulId) ->
    # dump ul metrics
    self = @
    ul = document.getElementById(ulId)
    space = @getULSpace(ul)
    console.log ul.id, $(ul).width(), space
    # dump li metrics
    total_width = 0
    $("li", ul).each (index, el) ->
      posId = $(el).data("id")
      width = $(el).width()
      total_width += width
      console.log ">>", $(el).data("id"), width, ">>", total_width
    ">>End Of Dump"

  updateSlotSpace: (ul, delta, li, position) ->
    @setDirty()
    self = @
    slotKey = @slotKey($(ul).data("fixture-item"), $(ul).data("layer"))
    space = @slotMap[slotKey]
    old_free_space = space.free
    space.free += delta

    if old_free_space > 0 && space.free <= 0
      $(ul).removeClass("sortable-container")
    else if old_free_space <= 0 && space.free > 0
      $(ul).addClass("sortable-container")

    oDiv = $($(ul).data("overflow"))
    if space.free >= 0
      oDiv.hide()
    else
      #console.log "show overflow..."
      overflow = ((space.merch_width - space.free) * 100.0) / space.merch_width
      oDiv.text("#{overflow.toFixed(1)}%").show().position
        of: ul
        collision: "none"

    # @log "free space updated:", $(ul).attr("id"), delta, old_free_space, space.free
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
  updateSlotItemColor: (li, position) ->
    product = @productMap[position.product_id]
    $("div.mdse-col", li).css "background-color", product[@showingColor]

  resetSlotItemGrid: (li, position) ->
    # create a rows x cols table in LI
    # leading_gap, leading_divider, col, middle_divider, col, trail_divider
    self = @
    li.empty()
    li_height = li.height()
    li_width = li.width()
    run = position.run
    # leading_gap
    if position.leading_gap > 0
      gap = "<div class='mdse-gap'></div>"
      width = (position.leading_gap * li_width / run).toFixed(1)
      $(gap).appendTo(li).css("width", width)
    # leading_divider
    divider = "<div class='mdse-divider'><div class='top-half'></div><div class='bottom-half'></div></div>"
    if position.leading_divider > 0
      width = (position.leading_divider * li_width / run).toFixed(1)
      $(divider).appendTo(li).css("width", width)

    # columns
    rows = position.height_units
    cols = position.width_units
    row = "<div class='mdse-unit'></div>"
    col = "<div class='mdse-col'></div>"
    product = @productMap[position.product_id]
    col_width = product.width * (li_width - 2)/ run
    for i in [1..cols]
      rowDivs = Array(rows+1).join(row)
      colDiv = $(col).appendTo(li).append(rowDivs).css
        "width": (col_width - 1).toFixed(1)
        "background-color": product[self.showingColor]
      if i < cols
        if position.middle_divider > 0
          width = (position.middle_divider * li_width / run).toFixed(1)
          $(divider).appendTo(li).css("width", width)
        else
          colDiv.addClass("collapse")

    # set property: color,height of each mdse-unit
    height = (li_height - (rows - 1)) / rows
    $("div.mdse-unit", li).height(height.toFixed(1))

    # trail_divider
    if position.trail_divider > 0
        width = (position.trail_divider * li_width / run).toFixed(1)
        $(divider).appendTo(li).css("width", width)

  updateSlotItemView: (li, position, ul) ->
    # update title of LI
    product = @productMap[position.product_id]
    title = "#{product.name} #{product.price_zone}"
    li.attr("title", title)

    # calculate height/width of LI
    slotKey = position.slotKey()
    space = @slotMap[slotKey]
    virtual_width = if space.free >= 0 then space.merch_width else (space.merch_width - space.free)
    height = position.height_units * product.height * $(ul).height() / space.merch_height
    # -2 to avoid overflow
    view_width = $(ul).width() - 2
    width = position.run * ($(ul).width() - 2) / virtual_width
    # -2 for selected border
    if li.hasClass("ui-selected")
      width -= 2
    li.css("width", "#{width.toFixed(1)}px")
    li.css("height", "#{height.toFixed(1)}px")

    @resetSlotItemGrid(li, position)

    # align LI to bottom of $(ul)
    total = $(ul).height()
    h = li.outerHeight()
    li.css("margin-top", (total - h).toFixed(1) + "px")

  selectSlotItem: (el, addMode) ->
    if !addMode
      for item in @selectedItems
        $(item.li).removeClass("ui-selected")
      @selectedItems = []
    if el?
      @selectedItems.push
        li: el
        position_id: $(el).data("id")
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
          this.run = this.leading_gap + this.leading_divider +
            product.width * this.facing +
            this.middle_divider * (this.facing - 1) +
            this.trail_divider

      for f,v of self.layout_fields
        val = $("##{prefix}_#{f}").val() || v
        val = parseFloat(val) if typeof v == "number"
        position[f] = val

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
      ul = item.ul
      fixture_item = ul.data("fixture-item")
      layer = ul.data("layer")
      console.log slot, ul
      console.log fixture_item, layer
      seq_num = 1
      $("li", ul).each (index, el) ->
        position_id = $(el).data("id")
        # self.log "setPlace", position_id, fixture_item, layer, seq_num
        self.positionMap[position_id].setPlace(fixture_item, layer, seq_num++)
        true

    # store positions to form INPUTs
    for position_id, position of @positionMap
      for f,v of @layout_fields
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

  popupMenu: (menuSel, el) ->
    menu = $(menuSel).menu().show().position
      my: "left top"
      at: "left bottom"
      of: el
    $(document).one "click", ()->
      console.log "hide popup menu by", this
      menu.hide()

  messageBox: (dlgId, onOk) ->
    $(dlgId).dialog
      resizable: true
      modal: true
      buttons:
        "取消": () ->
          $(this).dialog("close")
        "确认": () ->
          $(this).dialog("close")
          if onOk?
            onOk()

  openDialog: (dlgId, onInitDialog) ->
    if onInitDialog?
      onInitDialog($(dlgId))

    $(dlgId).dialog
      resizable: true
      width: $(dlgId).width()
      height: $(dlgId).height()
      modal: true
      buttons:
        "取消": () ->
          $(this).dialog("destroy")
        "确认": () ->
          $(this).dialog("destroy")
          $("form", this).submit()

  openJsDialog: (dlgId, dlgProc) ->
    dlg = $(dlgId)
    if dlgProc.init?
      dlgProc.init(dlg)

    $(dlgId).dialog
      resizable: true
      width: $(dlgId).width()
      height: $(dlgId).height()
      modal: true
      buttons:
        "取消": () ->
          $(this).dialog("destroy")
          if dlgProc.cancel?
            dlgProc.cancel(dlg)
        "确认": () ->
          $(this).dialog("destroy")
          if dlgProc.ok?
            dlgProc.ok(dlg)

  doSave: () ->
    $("#plan-layout-form").submit()

  onPlanSave: () ->
    @doSave()

  onPlanSwitchModelStore: (store_id) ->
    # /plans/13/edit?_do=layout
    re = new RegExp("/plans/\\d+/edit")
    href = window.location.href.replace(re, "/plans/#{store_id}/edit")
    #console.log "jump to", store_id, href
    window.location.replace(href)

  onPlanEditSummary: () ->
    @doSave()
    @openDialog("#plan-edit-summary-dialog")

  onPlanPublish: () ->
    self = @
    @messageBox "#plan-publish-confirm", () ->
      # TODO:
      console.log "publish it"
      self.doSave()
      $("#plan_published_at").val(new Date())
      $("#plan-publish-form").submit()

  setDlgStoreInfo: (info) ->
    $("#selected-store-fixture").text(info.fixture_name)
    $("#plan-usage-percent").text(info.finish_state.usage_percent)
    $("#plan-num-done-priors").text(info.finish_state.num_done_priors)
    $("plan-num-prior-products").text(info.finish_state.num_prior_products)
    $("plan-num-done-normals").text(info.finish_state.num_done_normals)
    $("plan-num-normal-products").text(info.finish_state.num_normal_products)

  onPlanCopyTo: () ->      # dup the plan to other model stores
    self = @
    plans_info = $("#selected-store-info").data("plans-info")
    @doSave()
    @openDialog "#plan-copy-to-dialog", (dlg) ->
      $("label[for^='plan_target_plans_']", dlg).click (event) ->
        planId = $("##{$(this).attr("for")}").val()
        self.setDlgStoreInfo(plans_info[planId])

      $("#store-info", dlg).click (event) ->
        thisPlanId = $("form", dlg).attr("action").match(/(\d+)$/)[1]
        self.setDlgStoreInfo(plans_info[thisPlanId])

  onPositionRemove: () ->
    if @selectedItems.length == 0
      console.log "no selected items"
    for item in @selectedItems
      el = item.li
      ul = el.parentNode
      $(el).remove() # remove LI element
      @removeItemFromSlot(el, ul)
    @selectedItems = []

  onPositionFacingInc: () ->
    item = @getActiveSlotItem()
    if item != null
      position_id = item.position_id
      position = @positionMap[position_id]
      @changePositionFacing(item.li, position, 1)

  onPositionFacingDec: () ->
    item = @getActiveSlotItem()
    if item != null
      position_id = item.position_id
      position = @positionMap[position_id]
      if position.facing > 1
        @changePositionFacing(item.li, position, -1)

  changePositionFacing: (li, position, delta) ->
    product = @productMap[position.product_id]
    old_run = position.recalcRun(product)
    position.facing += delta
    position.width_units += delta
    new_run = position.recalcRun(product)
    slotKey = position.slotKey()
    slotUL = @slotMap[slotKey].ul
    @updateSlotSpace(slotUL, old_run - new_run, $(li), position)

  onPositionsReorder: () ->
    if @selectedItems.length <= 1
      console.log "no selected items"
    else
      target = null
      for item in @selectedItems
        el = item.li
        ul = el.parentNode
        if target != null
          @moveSlotItemAfter(item, target)
        target = item

  moveSlotItemAfter: (item, target) ->
    return if target == null
    el = item.li
    ulFrom = el.parentNode
    ulTo = target.li.parentNode
    # move the html element first
    $(el).insertAfter(target.li)
    # update the item/slot space relation
    if ulFrom != ulTo
      console.log el, item.position_id, "change slot"
      @removeItemFromSlot(el, ulFrom)
      @addItemToSlot(el, ulTo)

  onPositionEditLeadingGaps: () ->
    self = @
    elId = "#plan_positions_attributes__leading_gap"
    if @selectedItems.length == 0
      return
    @openJsDialog "#plan-positions-gap-dialog",
      init: (dlg) ->
        console.log "init"
        # fill the form input with 1st selectedItem
        item = self.selectedItems[0]
        position = self.positionMap[item.position_id]
        $(elId).val(position.leading_gap)

      ok: (dlg) ->
        console.log "ok"
        new_gap = parseFloat $(elId).val()
        # set each position of selected items
        for item in self.selectedItems
          position = self.positionMap[item.position_id]
          product = self.productMap[position.product_id]
          old_run = position.recalcRun(product)
          if new_gap != position.leading_gap
            position.leading_gap = new_gap
            new_run = position.recalcRun(product)
            self.updateSlotSpace($(item.li).parent(), old_run - new_run, $(item.li), position)
        return true

  onPositionEditDividers: () ->
    self = @
    prefix = "#plan_positions_attributes_"
    fields = ["leading_divider", "middle_divider", "trail_divider"]
    @openJsDialog "#plan-positions-divider-dialog",
      init: (dlg) ->
        console.log "init"
        # fill the form input with 1st selectedItem
        item = self.selectedItems[0]
        position = self.positionMap[item.position_id]
        $("#{prefix}_leading_divider").val(position.leading_divider)
        $("#{prefix}_middle_divider").prop("checked", position.middle_divider > 0)
        $("#{prefix}_trail_divider").prop("checked", position.trail_divider > 0)

      ok: (dlg) ->
        pos =
          leading_divider: parseFloat($("#{prefix}_leading_divider").val())
          middle_divider: 0
          trail_divider: 0
        if $("#{prefix}_middle_divider").prop("checked")
          pos.middle_divider = pos.leading_divider
        if $("#{prefix}_trail_divider").prop("checked")
          pos.trail_divider = pos.leading_divider

        # set each position of selected items
        for item in self.selectedItems
          position = self.positionMap[item.position_id]
          product = self.productMap[position.product_id]
          old_run = position.recalcRun(product)
          # set new divider
          changed = false
          for f in fields
            if position[f] != pos[f]
              position[f] = pos[f]
              changed = true
          if changed
            new_run = position.recalcRun(product)
            self.updateSlotSpace($(item.li).parent(), old_run - new_run, $(item.li), position)
        console.log "ok"
        return true

  onSelectShowingColors: (el) ->
    # show menu
    @popupMenu("#showing-colors-menu", el)

  onSwitchToColor: (color) ->
    self = @
    if @showingColor != color
      @showingColor = color
      # update color of all slot items with @showingColor
      for ul,space of @slotMap
        $("li", space.ul).each (index, li) ->
          position_id = $(li).data("id")
          position = self.positionMap[position_id]
          self.updateSlotItemColor(li, position)

$ ->
  window.myCmdUI = new CmdUI
  window.myCmdUI.init()

  window.planEditor = new PlanEditor
  window.planEditor.init()
  window.myCmdUI.addDelegate(window.planEditor)
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

  $("#menu").menu().hide()

  #############################################
