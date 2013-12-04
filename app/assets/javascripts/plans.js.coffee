root = exports ? this

class Position
  @newIndex: 0
  @layout_fields:
    product_id: "?"
    version: 0
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

  constructor: (index) ->
    @index = index
    @newIndex = @index + 1
    @prefix = "plan_positions_attributes_#{index}"  # id = plan_positions_attributes_0_id
    @id = null
    @index
    Position.newIndex = index + 1

  load: (el) ->
    for f,v of Position.layout_fields
      val = $("##{@prefix}_#{f}").val() || v
      val = parseFloat(val) if typeof v == "number"
      @[f] = val
    @id = parseInt(el.value)
    @run = 0
    @rank = -1
    @

  store: (version) ->
    for f, _ of Position.layout_fields
      $("##{@prefix}_#{f}").val(@[f])
    $("##{@prefix}_version").val(version)
    true

  removeNull: () ->
    if @new && !@isOnShelf()
      $("input[id^=#{@prefix}_]").remove()
      @
    else
      null

  dup: () ->
    position = new Position(Position.newIndex)

    form = $("#plan-layout-form")
    fields = Position.layout_fields
    fields.id = null # add a field of id
    for f, _ of fields
      # dup property
      position[f] = @[f]
      # dup form input element
      el = $("##{@prefix}_#{f}").clone().appendTo(form)
      el.attr("id", "#{position.prefix}_#{f}")
      el.attr("name", "plan[positions_attributes][#{position.index}][#{f}]")
    position.id = null   # the
    el = $("##{position.prefix}_id")
    el.val(null)
    position.layer = -1
    position.rank = -1
    position.seq_num = -1
    position.fixture_item_id = -1
    position.run = 0
    position.new = true
    position.product = @product
    position

  isOnShelf: () ->
    @fixture_item_id > 0 && @layer > 0 && @seq_num >= 0

  offShelf: () ->
    @fixture_item_id = -1
    @layer = -1
    @seq_num = -1
    # DON'T clear facing/width_units, will cause drag/drop bug:
    #   failed to get facing
    # this.facing = 0
    # this.width_units = 0

  setPlace: (fixture_item_id, layer, seq_num, product) ->
    @fixture_item_id = fixture_item_id
    @layer = layer
    @seq_num = seq_num
    return @recalcRun(product)

  getLi: () ->
    $("li[data-id=#{@index}]")

  recalcRun: (product) ->
    # TODO: add precious version for calculate run
    if @isOnShelf()
      @leading_gap + @leading_divider +
        product.width * @facing +
        @middle_divider * (@facing - 1) +
        @trail_divider
    else
      0

  getWidth: () ->
    return 0 unless @isOnShelf()
    return @leading_gap + @leading_divider + @product.width * @facing +
      @middle_divider * (@facing - 1) + @trail_divider

  getHeight: () ->
    return 0 unless @isOnShelf()
    @product.height * @height_units

  getDepth: () ->
    return 0 unless @isOnShelf()
    @product.depth * @depth_units

  updateColor: (animate) ->
    if @bbox
      @bbox.attr("fill", @product.showingColor)
    if @border
      if $("li[data-id=#{@index}]").hasClass("ui-selected")
        @border.attr("stroke", "yellow").attr("stroke-width", 2)
      else
        @border.attr("stroke", "").attr("stroke-width", 0)

  draw: (li, options) ->
    cx = $(li).width()
    cy = $(li).height()
    paper = Raphael(li, cx, cy)
    paper.clear

    # draw block bounding box
    @bbox = paper.rect(0, 0, cx, cy)
      .attr("fill", @product.showingColor)

    xRatio = cx / @getWidth()
    yRatio = cy / @getHeight()
    console.log "ratio, x:#{xRatio}, y:#{yRatio}"

    # draw a rows x cols table in LI
    # leading_gap, leading_divider, col, middle_divider, col, trail_divider
    rows = @height_units
    cols = @width_units
    x = @leading_gap * xRatio # skip leading_gap

    # draw leading divider
    if @leading_divider > 0
      width = @leading_divider * xRatio
      paper.rect(x, cy / 2, width, cy / 2).attr("fill", "black")
      paper.line(x + width / 2, 0, x + width / 2, cy).attr("stroke", "black")
      x += width

    # draw block rect
    width = (@product.width * cols + @middle_divider * (cols - 1)) * xRatio
    paper.rect(x, 0, width, cy)
      .attr("stroke", "black")

    run = @product.width + (@product.width + @middle_divider) * (cols - 1)
    x1 = x
    x2 = x + run * xRatio

    # draw units grid: vert line
    for i in [1..cols - 1] by 1
      x = x1 + @product.width * i * xRatio
      paper.line(x, 0, x, cy)
        .attr("stroke", "black")
    xpos = []
    if @middle_divider > 0
      xpos.push [x1, x1 + @product.width * xRatio]
      for i in [1..cols - 1] by 1
        x = x1 + (@product.width + @middle_divider) * i * xRatio
        paper.line(x, 0, x, cy)
          .attr("stroke", "black")
        xpos.push [x, x1 + @product.width * (i + 1) * xRatio]
      xpos.push [x2 - @product.width * xRatio, x2]

    # draw units grid: horz line
    y = 0
    if @middle_divider > 0
      for i in [1..rows - 1] by 1
        y = (@product.height * i) * yRatio
        for x in xpos
          paper.line(x[0], y, x[1], y)
            .attr("stroke", "black")
    else
      for i in [1..rows - 1] by 1
        y = (@product.height * i) * yRatio
        paper.line(x1, y, x2, y)
          .attr("stroke", "black")

    # trail_divider
    if @trail_divider > 0
      width = @trail_divider * xRatio
      paper.rect(x2, cy / 2, width, cy / 2)
        .attr("fill", "black")
      paper.line(x2 + width / 2, 0, x2 + width / 2, cy / 2)
        .attr("stroke", "black")

    # draw border to indicate selected
    @border = paper.rect(0, 0, cx, cy)
    return

class PlanEditor
  @foo: 0
  slotMap: {}     # slot => [ul, space]
  positionMap: {} # position id => position
  sortedProducts: [] # product with run/rank
  productMap: {}  # product_id => position_index, code, name, :price_zone, height, width, depth
  showingColor: "color" # product color
  debug: true
  editVersion: 0 # for plan layout editor
  savedVersion: 0 # for plan layout editor
  liIndex: 0
  activeSlotUL: null
  selectedItems: [] # [li, position_index]
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
    for _, position of @positionMap
      @updateTableFacing(position.product_id)
    for _, product of @productMap
      @dataTable.updateProductRank(product)

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
    for _, product of @productMap
      product.color ||= "#CC0000"
      product.brand_color = brands[product.brand_id] || "#CCCC00"
      product.mfr_color = mfrs[product.mfr_id] || "#CC00CC"
      product.supplier_color = suppliers[product.supplier_id] || "#00CCCC"
      product.showingColor = product.color
      product.run = 0
      product.rank = -1

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
      positions = slotPosition[slot] # [position_index, seq_num, ..]
      # add items if exists
      if positions
        positions.sort (a, b) ->
          (a.seq_num - b.seq_num)
        for position in positions
          @newSlotItem(position, ul)
    @setSaved(@editVersion)

  newSlotItem: (position, ul) ->
    li = $("<li id='pos_#{@liIndex++}' class='sortable-item' data-id='#{position.index}'></li>").appendTo(ul)
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
    position_index = $(li).data("id")
    position = @positionMap[position_index]
    product = @productMap[position.product_id]
    new_run = position.setPlace($(ul).data("fixture-item"), $(ul).data("layer"), 0, product)
    @updatePositionRun(position, new_run)
    @updateSlotSpace(ul, 0, $(li), position)

  removeItemFromSlot: (li, ul) ->
    # 1. unset place info for position: fixture-item/layer
    # 2.+3. very like above addItemToSlot work flow
    position_index = $(li).data("id")
    position = @positionMap[position_index]
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
    @sortedProducts = []
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

      console.log "verified err:", err, @sortedProducts
    true

  verifyProductRank: () ->
    return true if @sortedProducts.length == 0
    err = 0
    prev_rank = 0
    prev_run = @sortedProducts[0].run
    index = 0
    for position in @sortedProducts
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

    #if position.id == "105"
    #  console.log "break"
    product = position.product
    updated_run = product.run + new_run - position.run
    max = @sortedProducts.length - 1

    # when delete old, items in (old_index, max], rank -= 1
    # expand old rank to min_index, max_index
    if product.rank >= 0
      max_index = min_index = product.rank # the 1st position with same rank
      while max_index < max && @sortedProducts[max_index + 1].rank == product.rank
        max_index++
      # find the true old index
      old_index = @sortedProducts.indexOf(product, min_index)
    else
      max_index = max + 1 # out of the end of list
      old_index = -1

    # when insert new, items in [new_index, max], rank += 1
    # therefore, expand insert point to right when posible
    if updated_run < 0.1 || max < 0 || @sortedProducts[max].run >= updated_run
      new_index = max + 1 # to the end of list
    else
      new_index = @binarySearch @sortedProducts, (pos) ->
        pos.run - updated_run # in desc order
      while new_index <= max && @sortedProducts[new_index].run >= updated_run # float==
        new_index++

    # calculate new rank
    if updated_run < 0.1
      new_rank = -1
    else if new_index == 0 || @sortedProducts[new_index - 1].run > updated_run
      new_rank = new_index
    else
      new_rank = @sortedProducts[new_index - 1].rank

    # update ranks of the modified items by insert/delete
    # (max_index, new_index) --, or,  [new_index, max_index] ++
    if max_index < new_index
      new_rank--
      for i in [(max_index + 1)...new_index] by 1
        @sortedProducts[i].rank--
    else
      rindex = Math.min(max_index, max)
      for i in [new_index..rindex] by 1
        @sortedProducts[i].rank++

    # modify the array
    if old_index != new_index
      # insert new
      if new_rank >= 0
        @sortedProducts.splice(new_index, 0, product)

      # than remove old
      if old_index >= 0
        if old_index > new_index
          old_index++
        @sortedProducts.splice(old_index, 1)

    #console.log @sortedProducts.length, "update rank, id:", position.id, "new_run:", new_run, "rank:", new_rank
    product.run = updated_run
    product.rank = new_rank
    position.run = new_run
    @updateTableRanks()

  updateTableRanks: () ->
    # update rank for all positions to dataTable
    if @dataTable != null
      for product in @sortedProducts
        @dataTable.updateProductRank(product)
    return true

  updateTableFacing: (product_id) ->
    if @dataTable != null
      product = @productMap[product_id]

    if product
      indices = product.position_index
      init_facing = null
      if indices
        run = 0
        facing = 0
        for index in indices
          position = @positionMap[index]
          if position
            init_facing ||= position.init_facing
            if position.isOnShelf()
              facing += position.facing
              run += position.getWidth()
      if init_facing
        @dataTable.updateProductFacing(product_id, init_facing, facing)
        product.run = run

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
      position_index = $(el).data("id")
      position = self.positionMap[position_index]
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
      li.empty()
      position.draw(li[0])

  getSlotWidths: (ul) ->
    pixels_width = 0
    extras_total = 0
    runs_total = 0
    self = @
    $("li", ul).each (index, el) ->
      position_index = $(el).data("id")
      runs_total += self.positionMap[position_index].run
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
    title = "#{product.code} #{product.name}"
    title += " #{product.price_zone}" if product.price_zone
    li.attr("title", title)

    # resize vert
    slotKey = @slotKey(position.fixture_item_id, position.layer)
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
    changed = []
    if !addMode
      # empty old selection
      for item in @selectedItems
        $(item.li).removeClass("ui-selected")
        position = @positionMap[item.position_index]
        if position
          position.updateColor()
      @selectedItems = []

    if el?
      # add to selection
      li = $(el)
      position_index = $(el).data("id")
      @selectedItems.push
        li: el
        position_index: position_index
      li.addClass("ui-selected")
      position = @positionMap[position_index]
      if position
        position.updateColor(true)

  getActiveSlotItem: () ->
    if @selectedItems.length == 1
      @selectedItems[0]
    else
      null

  # load initial positions from form/input
  loadPosition: () ->
    self = @
    @editVersion = parseInt $("#plan_version").val()
    console.log "init position"
    @positionMap = {}
    slotPosition = {}
    $("#plan-layout-form input[name^='plan[positions_attributes]['][name$='[id]']").each (index,el) ->
      # load, then add to positionMap
      position = new Position(index)
      position.load(el)
      self.positionMap[position.index] = position

      # link with product
      product_id = position.product_id
      position.product = self.productMap[product_id]

      # mark position to productMap
      self.productMap[product_id] ||= {}
      self.productMap[product_id].position_index ||= []
      self.productMap[product_id].position_index.push position.index

      # save position to slotPosition
      slot = self.slotKey(position.fixture_item_id, position.layer)
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
    version = @editVersion
    $("#plan_version").val(version)
    for slot,item of @slotMap
      ul = item.ul
      fixture_item = ul.data("fixture-item")
      layer = ul.data("layer")
      console.log slot, ul
      console.log fixture_item, layer
      seq_num = 1
      $("li", ul).each (index, el) ->
        position_index = $(el).data("id")
        position = self.positionMap[position_index]
        product = self.productMap[position.product_id]
        # self.log "setPlace", position_index, fixture_item, layer, seq_num
        position.setPlace(fixture_item, layer, seq_num++, product)
        true

    # store positions to form INPUTs
    for _, position of @positionMap
      if position.removeNull()
        # remove from index maps
        indice = @productMap[position.product_id].position_index
        i = indice.indexOf(position.index)
        if i >= 0
          indice.splice(i, 1)
        @positionMap[position.index] = null
      else
        position.store(version)
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
    positions = product.position_index
    if positions == null
      console.log "new product, refresh page"
      return false
    if @activeSlotUL == null
      @log "new position ignored, no active slot", product_id
    else
      layer = $(@activeSlotUL).data("layer")
      isOnLayer = false
      position = null
      for index in positions
        p = @positionMap[index]
        if p
          if p.layer == layer
            isOnLayer = true
          if position == null && !p.isOnShelf()
            position = p
      if isOnLayer
        @log "new position ignored, already on shelf", product_id, layer, positions
      else
        if position == null
          # no null position available, dup it
          @log "dup a position to layer", layer, positions[0]
          position = @positionMap[positions[0]].dup()
          @positionMap[position.index] = position
          @productMap[product_id].position_index.push position.index
          @log "position duped:", position
        @log "new position added", product_id, @activeSlotUL
        @newSlotItem(position, @activeSlotUL)
        position.getLi().click (e) ->
          self.selectSlotItem(this, e.ctrlKey)
          self.setActiveSlot(this.parentElement, e.ctrlKey && self.selectedItems.length > 1)
          e.stopPropagation()
        @updateTableFacing(product_id)
    return true

  onProductOffShelf: (product_id) ->
    product = @productMap[product_id]
    return unless product.position_index
    for i in product.position_index
      position = @positionMap[i]
      if position == null
        console.log "new product or removed position, do nothing"
      else if !position.isOnShelf()
        @log "position ignored, already off shelf", product_id, position
      else
        @log "position removed", product_id
        @removePosition(position)
        @updateTableFacing(product_id)
      return true

  removePosition: (position) ->
    if !position.isOnShelf()
      return
    skey = @slotKey(position.fixture_item_id, position.layer)
    ul = @slotMap[skey].ul
    li = position.getLi()
    li.remove() # remove LI element
    @removeItemFromSlot(li.get(0), ul)
    @updateTableFacing(position.product_id)
    @selectedItems = []

  onProductSelect: (product_id) ->
    product = @productMap[product_id]
    return unless product.position_index
    addSelect = false
    for index in product.position_index
      position = @positionMap[index]
      if position == null
        console.log "new product or removed position, do nothing"
        return false
      li = $("li[data-id='#{index}']").get(0)
      @selectSlotItem(li, addSelect)
      $(li).flash()
      addSelect = true
    return true

  onPositionRemove: () ->
    if @selectedItems.length == 0
      console.log "no selected items"
    for item in @selectedItems
      el = item.li
      position = @positionMap[item.position_index]
      ul = el.parentNode
      $(el).remove() # remove LI element
      @removeItemFromSlot(el, ul)
      @updateTableFacing(position.product_id)
    @selectedItems = []
    true

  onPositionFacingInc: () ->
    item = @getActiveSlotItem()
    if item != null
      position_index = item.position_index
      position = @positionMap[position_index]
      @changePositionFacing(item.li, position, 1)
    true

  onPositionFacingDec: () ->
    item = @getActiveSlotItem()
    if item != null
      position_index = item.position_index
      position = @positionMap[position_index]
      if position.facing > 1
        @changePositionFacing(item.li, position, -1)
    true

  changePositionFacing: (li, position, delta) ->
    product = @productMap[position.product_id]
    old_run = position.recalcRun(product)
    position.facing += delta
    position.width_units += delta
    new_run = position.recalcRun(product)
    slotKey = @slotKey(position.fixture_item_id, position.layer)
    slotUL = @slotMap[slotKey].ul
    @updatePositionRun(position, new_run)
    @updateSlotSpace(slotUL, old_run, $(li), position)
    @updateTableFacing(position.product_id)

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
      console.log el, item.position_index, "change slot"
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
        position = self.positionMap[item.position_index]
        $(elId).val(position.leading_gap)

      ok: (dlg) ->
        console.log "ok"
        new_gap = parseFloat $(elId).val()
        # set each position of selected items
        for item in self.selectedItems
          position = self.positionMap[item.position_index]
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
        position = self.positionMap[item.position_index]
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
          position = self.positionMap[item.position_index]
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
      for _, product of @productMap
        product.showingColor = product[@showingColor]
      # update color of all slot items with @showingColor
      for ul, space of @slotMap
        $("li", space.ul).each (index, li) ->
          position_index = $(li).data("id")
          position = self.positionMap[position_index]
          if position
            position.updateColor()
    return true

class ProductTable
  fields: []
  fieldsMap: {}
  planEditor: null
  table: null
  selected: []
  show_grade: ""
  productData: [] # [code,grade]
  productIndex: {}
  maxRank: 1

  onShowProductGrade: (el) ->
    self = @
    grade = el.value
    if self.show_grade != grade
      self.show_grade = grade
      console.log "show grade:", self.show_grade
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
    # initialize dataTable grade filter
    $.fn.dataTableExt.afnFiltering.push (oSettings, aData, iDataIndex) ->
      # filter grade
      # console.log "filter: ", iDataIndex, aData
      if self.show_grade == ""
        return true
      # if not show all, then show selected grade
      return self.productData[iDataIndex][1] == self.show_grade

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
    @productData = $("#products-data").data("grade")
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

  updateProductRank: (product) ->
    rank_index = @fieldsMap["plan_info_rank"] || -1
    if rank_index < 0
      console.log "cannot find rank field"
      return false

    product_id = product.code
    oTable = @table.dataTable()
    tr = oTable.$("tr[data-id='#{product_id}']")
    if tr && tr.length > 0
      tds = $("td", tr)
      rank_text = if product.rank >= 0 then product.rank + 1 else ""
      tds.eq(rank_index).text("#{rank_text}")

    row = @productIndex[product_id]
    data = oTable.fnSettings().aoData[row]
    data._aData[rank_index] = rank_text
    data._aSortData[rank_index] = if product.rank >= 0 then product.rank else @maxRank
    return true

  # update facing/init_facing
  updateProductFacing: (product_id, init_facing, facing) ->
    facing_index = @fieldsMap["facings"]
    if facing_index < 0
      console.log "cannot find facings field"
      return false

    oTable = @table.dataTable()
    tr = oTable.$("tr[data-id='#{product_id}']")
    # console.log tr
    facing_text = "#{facing}»#{init_facing}"
    if tr && tr.length > 0
      tds = $("td", tr)
      tds.eq(facing_index).text(facing_text)

    row = @productIndex[product_id]
    data = oTable.fnSettings().aoData[row]
    facing = facing + 1 / (init_facing + 2)
    data._aData[facing_index] = facing
    data._aSortData[facing_index] = facing
    return true

root.PlanPage = class PlanPage
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

    # init jqueryui selected
    $("ol.selectable.single-select").selectable
      selected: (e, ui) ->
        $(this).find("li").removeClass("ui-selected")
        $(ui.selected).addClass("ui-selected")
        $.util.execCmd $(ui.selected).data("cmd-id"), ui.selected

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

