root = exports ? this

class PlanEditor
  slotMap: {}     # slot => [ul, space]
  positionMap: {} # position id => position
  sortedPositions: [] # position
  productMap: {}  # product_id => position_id, code, name, :price_zone, height, width, depth
  showingColor: "color" # product color
  debug: true
  editVersion: 0 # for plan layout editor
  savedVersion: 0 # for plan layout editor
  liIndex: 0
  activeSlotUL: null
  selectedItems: [] # [li, position_id]
  dataTable: null

  layout_fields:
    product_id: "?"
    fixture_item_id: -1
    layer: -1
    seq_num: -1
    run: 0
    init_facing: 1
    facing: 1
    height_units: 0
    width_units: 0
    depth_units: 0
    leading_gap: 0
    leading_divider: 0
    middle_divider: 0
    trail_divider: 0

  constructor: (action, do_what) ->

  log: () ->
    if @debug
      console.log.apply(console, arguments)

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

  initDataTable: (dataTable) ->
    @dataTable = dataTable
    @updateTableRanks()
    for id,position of @positionMap
      @updateTableFacing(position)

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

    $(root).unload () ->
      self.save()

    # to install auto-save timer
    @save()

  initProductMap: () ->
    @productMap = $("#products-data").data("products")
    brands = $("#products-data").data("brands")
    mfrs = $("#products-data").data("mfrs")
    suppliers = $("#products-data").data("suppliers")
    for id,product of @productMap
      product.color ||= "#CC0000"
      product.brand_color = brands[product.brand_id] || "#CCCC00"
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
          (a.seq_num - b.seq_num)
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
    # position.recalcRun(product)
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
    product = @productMap[position.product_id]
    new_run = position.setPlace($(ul).data("fixture-item"), $(ul).data("layer"), 0, product)
    @updatePositionRun(position, new_run)
    @updateSlotSpace(ul, 0, $(li), position)

  removeItemFromSlot: (li, ul) ->
    # 1. unset place info for position: fixture-item/layer
    # 2.+3. very like above addItemToSlot work flow
    position_id = $(li).data("id")
    position = @positionMap[position_id]
    old_run = position.run
    position.offShelf()
    @updatePositionRun(position, 0)
    @updateSlotSpace(ul, old_run, null, position)

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

  binarySearch: (arr, fn) ->
    lo = 0
    hi = arr.length
    while lo < hi
      mid = Math.floor((lo + hi) / 2)
      cmp = fn(arr[mid])
      if cmp == 0
        return mid
      else if cmp > 0 # val > arr[mid]
        lo = mid + 1
      else
        hi = mid
    return lo # insert at right

  test: () ->
    map = {}
    tests = [
      (id: 1, run: 0, rank: -1 )
      (id: 2, run: 0, rank: -1 )
      (id: 3, run: 0, rank: -1 )
      (id: 4, run: 0, rank: -1 )
    ]
    @sortedPositions = []
    for pos in tests
      map[pos.id] = pos

    tests = [
      (id: 1, new_run: 11, _rank: 0)
      (id: 2, new_run: 9, _rank: 1)
      (id: 3, new_run: 13, _rank: 0)
      (id: 4, new_run: 4, _rank: 3)
      (id: 4, new_run: 7, _rank: 3)
      (id: 4, new_run: 10, _rank: 2)
    ]
    for pos in tests
      p = map[pos.id]
      @updatePositionRun(p, pos.new_run)
      console.log "updateRun", p, p.rank, ":", pos._rank

      console.log "verified err:", err, @sortedPositions
    true

  verifyPositionRank: () ->
    return true if @sortedPositions.length == 0
    err = 0
    prev_rank = 0
    prev_run = @sortedPositions[0].run
    index = 0
    for position in @sortedPositions
      if position.run > prev_run
        console.log "wrong run", position, position.run, ":", prev_run
        err++
      if position.rank != index && position.rank != prev_rank
        console.log "wrong rank", position, position.rank, ":", prev_rank, "/", index
        err++
      prev_rank = position.rank
      prev_run = position.run
      index++
    console.log "position rank array verified, err:", err
    return err == 0

  updatePositionRun: (position, new_run) ->
    if Math.abs(position.run - new_run) < 0.1
      return false

    if position.id == "105"
      console.log "break"
    max = @sortedPositions.length - 1

    # when delete old, items in (old_index, max], rank -= 1
    # expand old rank to min_index, max_index
    if position.rank >= 0
      max_index = min_index = position.rank # the 1st position with same rank
      while max_index < max && @sortedPositions[max_index + 1].rank == position.rank
        max_index++
      # find the true old index
      old_index = @sortedPositions.indexOf(position, min_index)
    else
      max_index = max + 1 # out of the end of list
      old_index = -1

    # when insert new, items in [new_index, max], rank += 1
    # therefore, expand insert point to right when posible
    if new_run < 0.1 || max < 0 || @sortedPositions[max].run >= new_run
      new_index = max + 1 # to the end of list
    else
      new_index = @binarySearch @sortedPositions, (pos) ->
        pos.run - new_run # in desc order
      while new_index <= max && @sortedPositions[new_index].run >= new_run # float==
        new_index++

    # calculate new rank
    if new_run < 0.1
      new_rank = -1
    else if new_index == 0 || @sortedPositions[new_index - 1].run > new_run
      new_rank = new_index
    else
      new_rank = @sortedPositions[new_index - 1].rank

    # update ranks of the modified items by insert/delete
    # (max_index, new_index) --, or,  [new_index, max_index] ++
    if max_index < new_index
      new_rank--
      for i in [(max_index + 1)...new_index] by 1
        @sortedPositions[i].rank--
    else
      rindex = Math.min(max_index, max)
      for i in [new_index..rindex] by 1
        @sortedPositions[i].rank++

    # modify the array
    if old_index != new_index
      # insert new
      if new_rank >= 0
        @sortedPositions.splice(new_index, 0, position)

      # than remove old
      if old_index >= 0
        if old_index > new_index
          old_index++
        @sortedPositions.splice(old_index, 1)

    #console.log @sortedPositions.length, "update rank, id:", position.id, "new_run:", new_run, "rank:", new_rank
    position.run = new_run
    position.rank = new_rank
    @updateTableRanks()

  updateTableRanks: () ->
    # update rank for all positions to dataTable
    if @dataTable != null
      for pos in @sortedPositions
        @dataTable.updateProductRank(pos)
    return true

  updateTableFacing: (position) ->
    if @dataTable != null
      @dataTable.updateProductFacing(position)

  updateSlotSpace: (ul, old_run, li, position) ->
    @setDirty()
    self = @
    slotKey = @slotKey($(ul).data("fixture-item"), $(ul).data("layer"))
    space = @slotMap[slotKey]
    old_free_space = space.free
    space.free += old_run - position.run

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
      @resizeAllSlotItems(ul)
      #$("li", ul).each (index, el) ->
      #  position_id = $(el).data("id")
      #  self.updateSlotItemView $(el), self.positionMap[position_id], ul
      #  true
    else if li != null # removed item
      # update the changed item only
      @updateSlotItemView(li, position, ul)

  # update item view: height,width/title/grids/align_bottom
  updateSlotItemColor: (li, position) ->
    product = @productMap[position.product_id]
    $("div.mdse-col", li).css "background-color", product[@showingColor]

  resetSlotItemGrid: (li, position, width_total) ->
    # create a rows x cols table in LI
    # leading_gap, leading_divider, col, middle_divider, col, trail_divider
    self = @
    li.empty()

    # fairly distribute the height
    rows = position.height_units
    height_total = li.height() + 1 # for mdse-col, top-border-width
    row_heights = []
    rows_remain = rows
    row = "<div class='mdse-unit'></div>"
    for i in [1..rows] by 1
      pixel = Math.floor(height_total / rows_remain)
      # border-bottom-width: 1px
      row_heights.push pixel - 1
      height_total -= pixel
      rows_remain--

    # fairly distribute the width
    width_total-- # mdse-col: border 1px on both sides
    run_total = position.run
    getWidth = (run, extra = 0) ->
      pixel = Math.floor(run * width_total / run_total)
      width_total -= pixel
      run_total -= run
      pixel - extra

    # leading_gap
    if position.leading_gap > 0
      gap = "<div class='mdse-gap'></div>"
      $(gap).appendTo(li).width getWidth(position.leading_gap)

    # leading_divider
    divider = "<div class='mdse-divider'><div class='top-half'></div><div class='bottom-half'></div></div>"
    if position.leading_divider > 0
      $(divider).appendTo(li).width getWidth(position.leading_divider)

    # columns
    product = @productMap[position.product_id]
    col_run = product.width
    cols = position.width_units
    col = "<div class='mdse-col'></div>"
    for i in [1..cols] by 1
      rowDivs = Array(rows+1).join(row)
      colDiv = $(col).appendTo(li).append(rowDivs).css
        "width": getWidth(col_run, 1)
        "background-color": product[self.showingColor]
      if i < cols
        if position.middle_divider > 0
          $(divider).appendTo(li).width getWidth(position.middle_divider)
        else
          colDiv.addClass("collapse")
      # set property: height of each mdse-unit
      $("div.mdse-unit", colDiv).each (index, el)->
        $(el).height row_heights[index]

    # trail_divider
    if position.trail_divider > 0
        width = (position.trail_divider * li_width / run).toFixed(1)
        $(divider).appendTo(li).width getWidth(position.trail_divider)

  # update all items in slot
  resizeAllSlotItems: (ul) ->
    self = @
    space = @getULSpace(ul)
    virt_width = if space.free >= 0 then space.merch_width else (space.merch_width - space.free)
    # make a fair distributions of pixels
    console.log "virt-width:", virt_width, "pixels"
    total = @getSlotWidths(ul)
    width = $(ul).width() - 2 - total.extra # for borders and margins
    $("li", ul).each (index, el) ->
      position_id = $(el).data("id")
      position = self.positionMap[position_id]
      self.resizeSlotItemVert(ul, $(el), position, space)
      pixel = Math.floor(width * position.run / virt_width)
      self.resizeSlotItemHorz($(el), position, pixel)
      virt_width -= position.run
      width -= pixel

  resizeSlotItemVert: (ul, li, position, space) ->
    product = @productMap[position.product_id]

    # set height
    extra = li.outerHeight() - li.height()
    height = Math.floor position.height_units * product.height * $(ul).height() / space.merch_height
    li.height(height - extra)

    # align LI to bottom of ul: set margin-top
    li.css("margin-top", ($(ul).height() - height) + "px")

  resizeSlotItemHorz: (li, position, width) ->
    old_width = li.width()
    if old_width != width
      li.width(width)
      # resize items inside LI
      @resetSlotItemGrid(li, position, width)

  getSlotWidths: (ul) ->
    pixels_width = 0
    extras_total = 0
    runs_total = 0
    self = @
    $("li", ul).each (index, el) ->
      position_id = $(el).data("id")
      runs_total += self.positionMap[position_id].run
      extras_total += $(el).outerWidth(true) - $(el).width()
      pixels_width += $(el).width()
      true
    widths =
      run: runs_total
      extra: extras_total
      pixel: pixels_width

  updateSlotItemView: (li, position, ul) ->
    # update title of LI
    product = @productMap[position.product_id]
    title = "#{product.name} #{product.price_zone}"
    li.attr("title", title)

    # resize vert
    slotKey = position.slotKey()
    space = @slotMap[slotKey]
    @resizeSlotItemVert(ul, li, position, space)

    # resize horz
    total = @getSlotWidths(ul)
    total.pixel -= $(li).width()
    width_total = $(ul).width() - total.extra
    if space.free > 0
      width_total = Math.floor(width_total * total.run / space.merch_width)
    else
      width_total-- # leave a pixel at right side
    width = width_total - total.pixel # for this LI
    @resizeSlotItemHorz(li, position, width)

  selectSlotItem: (el, addMode) ->
    if !addMode
      for item in @selectedItems
        $(item.li).removeClass("ui-selected")
      @selectedItems = []
    if el?
      li = $(el)
      position_id = $(el).data("id")
      @selectedItems.push
        li: el
        position_id: position_id
      li.addClass("ui-selected")
      position = @positionMap[position_id]
      #@resetSlotItemGrid(li, position, li.width()) # for yellow margin

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
          # DON'T clear facing/width_units, will cause drag/drop bug:
          #   failed to get facing
          # this.facing = 0
          # this.width_units = 0
        setPlace: (fixture_item_id, layer, seq_num, product) ->
          this.fixture_item_id = fixture_item_id
          this.layer = layer
          this.seq_num = seq_num
          return this.recalcRun(product)
        slotKey: () ->
          self.slotKey(this.fixture_item_id, this.layer)
        getLi: () ->
          $("li[data-id=#{this.id}]")
        recalcRun: (product) ->
          # TODO: add precious version for calculate run
          if this.isOnShelf()
            this.leading_gap + this.leading_divider +
              product.width * this.facing +
              this.middle_divider * (this.facing - 1) +
              this.trail_divider
          else
            0

      for f,v of self.layout_fields
        val = $("##{prefix}_#{f}").val() || v
        val = parseFloat(val) if typeof v == "number"
        position[f] = val
      # initial state, run=0, rank=-1
      position.run = 0
      position.rank = -1

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
        position = self.positionMap[position_id]
        product = self.productMap[position.product_id]
        # self.log "setPlace", position_id, fixture_item, layer, seq_num
        position.setPlace(fixture_item, layer, seq_num++, product)
        true

    # store positions to form INPUTs
    for position_id, position of @positionMap
      for f,v of @layout_fields
        $(position.input_id(f)).val(position[f])
    return true

  save: () ->
    return console.log "save"

    if @isDirty()
      console.log "submit!"
      $("#plan-layout-form").submit()

    self = @
    saveProc = () ->
      self.save()
    setTimeout(saveProc, 90000)  # 90s

  doSave: () ->
    $("#plan-layout-form").submit()

  onPlanSave: () ->
    @doSave()
    true

  onPlanSwitchModelStore: (el) ->
    # /plans/13/edit?_do=layout
    store_id = el.value
    re = new RegExp("/plans/\\d+/edit")
    href = root.location.href.replace(re, "/plans/#{store_id}/edit")
    #console.log "jump to", store_id, href
    root.location.replace(href)
    true

  onPlanEditSummary: () ->
    @doSave()
    $.util.openDialog("#plan-edit-summary-dialog")
    true

  onPlanClose: () ->
    self = @
    $.util.messageBox "#plan-close-confirm", () ->
      # TODO:
      console.log "close it"
      self.doSave()
      re = new RegExp("/plans/.*")
      href = root.location.href.replace(re, $("#plan_sets_index").attr("href"))
      root.location.replace(href)
      #console.log "jump to", store_id, href
    true

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
    $.util.openDialog "#plan-copy-to-dialog", (dlg) ->
      $("label[for^='plan_target_plans_']", dlg).click (event) ->
        planId = $("##{$(this).attr("for")}").val()
        self.setDlgStoreInfo(plans_info[planId])

      $("#store-info", dlg).click (event) ->
        thisPlanId = $("form", dlg).attr("action").match(/(\d+)$/)[1]
        self.setDlgStoreInfo(plans_info[thisPlanId])
    true

  onProductOnShelf: (product_id) ->
    self = @
    product = @productMap[product_id]
    position = @positionMap[product.position_id]
    if position == null
      console.log "new product, refresh page"
      return false
    if position.isOnShelf()
      @log "new position ignored, already on shelf", product_id, position
    else if @activeSlotUL == null
      @log "new position ignored, no active slot", product_id
    else
      @log "new position added", product_id, @activeSlotUL
      @newSlotItem(position, @activeSlotUL)
      position.getLi().click (e) ->
        self.selectSlotItem(this, e.ctrlKey)
        self.setActiveSlot(this.parentElement, e.ctrlKey && self.selectedItems.length > 1)
        e.stopPropagation()
      @updateTableFacing(position)
    return true

  onProductOffShelf: (product_id) ->
    product = @productMap[product_id]
    position = @positionMap[product.position_id]
    if position == null
      console.log "new product, refresh page"
      return false
    if !position.isOnShelf()
      @log "position ignored, already off shelf", product_id, position
    else
      @log "position removed", product_id
      @removePosition(position)
      @updateTableFacing(position)
    return true

  removePosition: (position) ->
    if !position.isOnShelf()
      return
    skey = position.slotKey()
    ul = @slotMap[skey].ul
    li = position.getLi()
    li.remove() # remove LI element
    @removeItemFromSlot(li.get(0), ul)
    @updateTableFacing(position)
    @selectedItems = []

  onProductSelect: (product_id) ->
    product = @productMap[product_id]
    position = @positionMap[product.position_id]
    if position == null
      console.log "new product, refresh"
      return false
    li = $("li[data-id='#{product.position_id}']").get(0)
    @selectSlotItem(li, false)
    return true

  onPositionRemove: () ->
    if @selectedItems.length == 0
      console.log "no selected items"
    for item in @selectedItems
      el = item.li
      position = @positionMap[item.position_id]
      ul = el.parentNode
      $(el).remove() # remove LI element
      @removeItemFromSlot(el, ul)
      @updateTableFacing(position)
    @selectedItems = []
    true

  onPositionFacingInc: () ->
    item = @getActiveSlotItem()
    if item != null
      position_id = item.position_id
      position = @positionMap[position_id]
      @changePositionFacing(item.li, position, 1)
    true

  onPositionFacingDec: () ->
    item = @getActiveSlotItem()
    if item != null
      position_id = item.position_id
      position = @positionMap[position_id]
      if position.facing > 1
        @changePositionFacing(item.li, position, -1)
    true

  changePositionFacing: (li, position, delta) ->
    product = @productMap[position.product_id]
    old_run = position.recalcRun(product)
    position.facing += delta
    position.width_units += delta
    new_run = position.recalcRun(product)
    slotKey = position.slotKey()
    slotUL = @slotMap[slotKey].ul
    @updatePositionRun(position, new_run)
    @updateSlotSpace(slotUL, old_run, $(li), position)
    @updateTableFacing(position)

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
    true

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
      return true
    $.util.openJsDialog "#plan-positions-gap-dialog",
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
            self.updatePositionRun(position, new_run)
            self.updateSlotSpace($(item.li).parent(), old_run, $(item.li), position)
        return true
    true

  onPositionEditDividers: () ->
    self = @
    prefix = "#plan_positions_attributes_"
    fields = ["leading_divider", "middle_divider", "trail_divider"]
    $.util.openJsDialog "#plan-positions-divider-dialog",
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
            self.updatePositionRun(position, new_run)
            self.updateSlotSpace($(item.li).parent(), old_run, $(item.li), position)
        console.log "ok"
        return true
    true

  onSwitchShowColors: (el) ->
    # show menu
    $.util.popupMenu "#showing-colors-menu",
      under: el
    true

  onShowBrandColor: () ->
    @onSwitchToColor("brand_color")

  onShowProductColor: () ->
    @onSwitchToColor("color")

  onShowManufacturerColor: () ->
    @onSwitchToColor("mfr_color")

  onShowSupplierColor: () ->
    @onSwitchToColor("supplier_color")

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
    true

class ProductTable
  fields: []
  fieldsMap: {}
  planEditor: null
  table: null
  selected: []
  show_sale_type: -1
  productData: [] # [code,sale_type]
  productIndex: {}
  maxRank: 1

  onShowProductSaleType: (el) ->
    self = @
    sale_type = parseInt(el.value)
    if self.show_sale_type != sale_type
      self.show_sale_type = sale_type
      console.log "show sale_type:", self.show_sale_type
      if self.table
        oTable = self.table.dataTable()
        if oTable
          oTable.fnDraw()
    true

  onProductsAddToShelf: () ->
    self = @
    if self.selected.length == 0
      console.log "no select prompt"
    else
      for el in self.selected
        self.addProductToShelf(el)
      console.log "products added"
    true

  onProductsRemoveFromShelf: () ->
    self = @
    if self.selected.length == 0
      console.log "no select prompt"
    else
      for el in self.selected
        self.removeProductFromShelf(el)
      console.log "products removed"
    true

  init: (tableId) ->
    self = @
    selected = []
    @table = $(tableId)
    @initFieldMapping()
    @initProductList()
    # initialize dataTable sale_type filter
    $.fn.dataTableExt.afnFiltering.push (oSettings, aData, iDataIndex) ->
      # filter sale_type
      # console.log "filter: ", iDataIndex, aData
      if self.show_sale_type == -1
        return true
      # if not show all, then show select sale_type
      return self.productData[iDataIndex][1] == self.show_sale_type

    $("tr", @table).click (e) ->
      console.log "select product", this
      self.selectProduct(this, e.ctrlKey)

    $("tr", @table).dblclick (event) ->
      console.log "product on-sale", this
      self.addProductToShelf(this)

    return self

  bind: (planEditor) ->
    @planEditor = planEditor
    if planEditor
      planEditor.initDataTable(@)
    return self

  initFieldMapping: () ->
    self = @
    $("th", @table).each (index, el) ->
      matches = []
      input = $(el).data("input")
      if input
        matches = input.match(/\[(\w+)\]/)
      if matches.length > 1
        self.fields.push matches[1]
        self.fieldsMap[matches[1]] = index
      else
        self.fields.push null

    oTable = @table.dataTable()
    columns = oTable.fnSettings().aoColumns
    rank_index = @fieldsMap["plan_info_rank"]
    columns[rank_index].sType = "numeric"
    facing_index = @fieldsMap["facings"]
    columns[facing_index].sType = "numeric"

  initProductList: () ->
    @productIndex = {}
    @productData = $("#products-data").data("sale-type")
    @maxRank = @productData.length
    index = 0
    for data in @productData
      @productIndex[data[0]] = index++

  selectReset: () ->
    for el in @selected
      #$("td", e).attr("bgcolor", null)
      $(el).css("background-color", "")
    @selected = []

  selectProduct: (el, addSel) ->
    if !addSel
      @selectReset()

    # not in old selection
    if @selected.indexOf(el) < 0
      @selected.push el
      # $("td", el).attr("bgcolor", "yellow")
      $(el).css("background-color", 'yellow')
      product_id = $(el).data("id")
      if @planEditor != null
        @planEditor.onProductSelect(product_id)

  addProductToShelf: (el) ->
    product_id = $(el).data("id")
    if @planEditor != null
      @planEditor.onProductOnShelf(product_id)
      @planEditor.onProductSelect(product_id)

  removeProductFromShelf: (el) ->
    product_id = $(el).data("id")
    if @planEditor != null
      @planEditor.onProductOffShelf(product_id)

  updateProductRank: (position) ->
    rank_index = @fieldsMap["plan_info_rank"] || -1
    if rank_index < 0
      console.log "cannot find rank field"
      return false

    product_id = position.product_id
    oTable = @table.dataTable()
    tr = oTable.$("tr[data-id='#{product_id}']")
    if tr && tr.length > 0
      tds = $("td", tr)
      rank_text = if position.rank >= 0 then position.rank + 1 else ""
      tds.eq(rank_index).text("#{rank_text}")

    row = @productIndex[product_id]
    data = oTable.fnSettings().aoData[row]
    data._aData[rank_index] = rank_text
    data._aSortData[rank_index] = if position.rank >= 0 then position.rank else @maxRank
    return true

  # update facing/init_facing
  updateProductFacing: (position) ->
    facing_index = @fieldsMap["facings"]
    if facing_index < 0
      console.log "cannot find facings field"
      return false

    product_id = position.product_id
    oTable = @table.dataTable()
    tr = oTable.$("tr[data-id='#{product_id}']")
    # console.log tr
    facing = if position.isOnShelf() then position.facing else 0
    facing_text = "#{facing}»#{position.init_facing}"
    if tr && tr.length > 0
      tds = $("td", tr)
      tds.eq(facing_index).text(facing_text)

    row = @productIndex[product_id]
    data = oTable.fnSettings().aoData[row]
    facing = facing + 1 / (position.init_facing + 2)
    data._aData[facing_index] = facing
    data._aSortData[facing_index] = facing
    return true

class PlanPage
  action: ""
  _do: ""

  constructor: (action, _do) ->
    console.log "create PlanPage"
    @action = action
    @_do = _do

  onLoadEditLayout: () ->
    root.planEditor = new PlanEditor
    root.planEditor.init()
    $.util.addCmdDelegate(root.planEditor)

    root.productTable = new ProductTable
    root.productTable.init("#products-table").bind(root.planEditor)
    $.util.addCmdDelegate(root.productTable)
    console.log "plans inited"
    return true

  test: () ->
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

root.PlanPage = PlanPage
