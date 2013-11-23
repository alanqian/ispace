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

  exec: (cmdId, el) ->
    @handle(cmdId, el)

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

  init: (option, container) ->
    self = @
    @delegates ||= [root]
    if option == "cmd-ui:toolbar" || option == null
      $(".toolbar-button", container).each (index, el) ->
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

      $(".toolbar-select", container).each (index, el) ->
        $(el).addClass("ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only")
        $(el).change (e) ->
          #console.log "change it", e, this, this.value
          self.handle(this.id, this)

    # initialize the popup menu width
    if option == "cmd-ui:popup-menu" || option == null
      $("ul.popup-menu", container).each (index, ul) ->
        self.setMenuItemWidth(ul)

      $("ul.popup-menu", container).menu().hide()
      $("ul.popup-menu", container).find("a").click (e) ->
        e.preventDefault()
        e.stopPropagation()
        # hide the outer popup menubox
        $(this).closest("ul.popup-menu").hide()
        id = $(this).data("id")
        self.handle(this.id, this)

    # initialize in-page cmd_ui anchor
    if option == "cmd-ui:anchor" || option == null
      $("a.cmd_ui[href='#'][id]", container).click (e) ->
        e.preventDefault()
        id = $(this).data("id")
        self.handle(this.id, this)
        return false
      return self

    # returns true
    return true

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
    # hide all other menu visible
    $("ul.ui-menu[role='menu']").hide()
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

  exists: (elementId) ->
    return document.getElementById(elementId) != null

  getMenuId: (cmdId) ->
    "ui-cmd-menu-#{cmdId}"

  findMenu: (cmdId) ->
    menuId = @getMenuId(cmdId)
    return document.getElementById(menuId)

  destoryMenu: (cmdId) ->
    menuId = @getMenuId(cmdId)
    $("##{menuId}").remove()

  createMenu: (cmdId, itemOrderList, opts) ->
    idField = opts.id
    parentIdField = opts.parent
    labelField = opts.label

    root = {}
    menu = @findMenu(cmdId)
    return menu if menu != null

    menuId = @getMenuId(cmdId)
    root[idField] = opts.rootId
    root[parentIdField] = null
    root.ul = $("<ul id='#{menuId}' data-id='#{cmdId}'></ul>").appendTo(document.body)
    parents = [root]
    for item in itemOrderList
      id = item[idField]
      parentId = item[parentIdField]
      # find parent item
      # console.log "append item", item
      parent = null
      while parent == null && node = parents.pop()
        if node[idField] == parentId
          parent = node
      if parent == null
        console.log "Invalid parent id error:", item, itemOrderList
        return null
      else
        parents.push parent
        parents.push item
        parent.ul ||= $("<ul></ul").appendTo(parent.li)
        item.li = $("<li></li>").append("<a data-id='#{id}'>#{item[labelField]}</a>").appendTo(parent.ul)
    @setMenuItemWidth(root.ul)
    root.ul.hide()
    return root.ul[0]

  popupMenuSelect: (el, opts) ->
    $menu = $(el)
    self = @
    id = $menu.data("id")
    srcElement = opts.srcElement
    menu = $menu.menu
      select: (e, ui) ->
        $anchor = ui.item.find("a:first-child")
        if srcElement
          $anchor.data("src-element", srcElement)
        self.handle(id, $anchor[0])
        $menu.hide()
    @showMenu(menu, opts)

  popupMenu: (menuSel, opts) ->
    menu = $(menuSel).menu()
    @showMenu(menu, opts)

root.cmdUI = new CmdUI()

