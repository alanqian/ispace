root = exports ? this

# Delegate command UI for
# 1. toolbar: ".toolbar-button", "toolbar-select"
# 2. popup-menu: "ul.pupop-menu"
# 3. create popup menu by json-data;
# eg:
#   menu = window.myCmdUI.createMenu "test", $("#plan_set_category_name").data("source"),
#     id: "code"
#     parent: "parent_id"
#     label: "name"
#     rootId: null
#     dom: "#test-menu"
#   window.myCmdUI.popupMenuSelect menu,
#     right: "#plan_set_category_name"
#
# class CmdDelegater
#   onTest: (el)
#     console.log $(el).data("id")
#     return true
class CmdUI
  delegates: null
  menuItemPadding: 28

  addDelegate: (obj) ->
    if obj?
      @delegates.unshift obj

  send: (cmdId) ->
    $("##{cmdId}").click()

  exec: (cmdId) ->
    handle(cmdId, null)

  handle: (id, el) ->
    test = {}
    fnName = _.str.camelize("on_#{id}")
    for delegate in @delegates
      fn = delegate[fnName]
      if fn && test.toString.call(fn) == "[object Function]"
        if fn.call(delegate, el)
          return true
    console.log "[CmdUI] ignore unhandled cmd:", id
    return false

  init: () ->
    self = @
    @delegates = [root]
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
    $("ul.popup-menu").each (index, ul) ->
      self.setMenuItemWidth(ul)

    $("ul.popup-menu").menu().hide()
    $("ul.popup-menu").find("a").click (e) ->
      e.preventDefault()
      e.stopPropagation()
      # hide the outer popup menubox
      $(this).closest("ul.popup-menu").hide()
      id = $(this).data("id")
      self.handle(this.id, this)

    @initCmdUIAnchor()


  initCmdUIAnchor: () ->
    # handle in-page cmd_ui anchors
    self = @
    $("a.cmd_ui[href='#'][id]").click (e) ->
      e.preventDefault()
      id = $(this).data("id")
      self.handle(this.id, this)
      return false
    return self

  setMenuItemWidth: (ul) ->
    self = @
    # initialize each popup item
    $(ul).data("maxChild", 0)
    $("li ul", ul).each (index, el) ->
      $(el).data "maxChild", 0

    $("li a", ul).each (index, el) ->
      popup = $(el).closest("ul")
      maxChild = popup.data("maxChild")
      width = $(el).width()
      if $(el).next("ul").length >= 1
        width += 20
      if maxChild < width
        popup.data("maxChild", width)

    # set the width of all popups
    $("li ul", ul).each (index, el) ->
      $(el).width($(el).data("maxChild") + self.menuItemPadding)
    $(ul).width($(ul).data("maxChild")+ self.menuItemPadding)

  showMenu: (menu, opts) ->
    pos =
      of: opts.under || opts.above || opts.left || opts.right
    if opts.under
      pos.my = "left top"
      pos.at = "left bottom"
    else if opts.above
      pos.my = "left bottom"
      pos.at = "left top"
    else if opts.left
      pos.my = "right top"
      pos.at = "left top"
    else
      pos.my = "left top"
      pos.at = "right top"
    menu.show().position(pos)
    $(document).one "click", ()->
      console.log "hide popup menu by", this
      menu.hide()

  createMenu: (menuId, itemOrderList, opts) ->
    idField = opts.id
    parentIdField = opts.parent
    labelField = opts.label

    root = {}
    root[idField] = opts.rootId
    root[parentIdField] = null
    root.ul = $("<ul id='#{menuId}'></ul>").appendTo(opts.dom)
    parents = [root]
    for item in itemOrderList
      id = item[idField]
      parentId = item[parentIdField]
      # find parent item
      # console.log "append item", item
      parent = null
      while node = parents.pop()
        if node[idField] == parentId
          parent = node
          break
      if parent == null
        console.log "Invalid parent id error:", item
        return null
      else
        parents.push parent
        parents.push item
        parent.ul ||= $("<ul></ul").appendTo(parent.li)
        item.li = $("<li></li>").append("<a data-id='#{id}' data-src-element='#{opts['srcElement']}'>#{item[labelField]}</a>").appendTo(parent.ul)
    @setMenuItemWidth(root.ul)
    root.ul.hide()
    return root.ul

  popupMenuSelect: (menuSel, opts) ->
    self = @
    id = $(menuSel).attr("id")
    menu = $(menuSel).menu
      select: (e, ui) ->
        anchor = ui.item.find("a")[0]
        self.handle(id, anchor)
        $(menuSel).hide()
    @showMenu(menu, opts)

  popupMenu: (menuSel, opts) ->
    menu = $(menuSel).menu()
    @showMenu(menu, opts)

root.cmdUI = new CmdUI()

