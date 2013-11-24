root = exports ? this

# For category input, a user can type this:
#   category code, :value
#   category name, :label
#   pinyin of category name, :pinyin
#   short pinyin of category name, :py
# source:
#   label: is displayed in the suggestion menu
#   value: will be inserted into the input element when a user selects an item
# eg:
#     <%= f.hidden_field :category_id %>
#     <%= f.input :category_name, input_html: {
#       for: "plan_set_category_id",
#       class: "auto-complete",
#       data: {
#         source: @categories_all.to_json,
#         value: "code",
#         labels: ["name", "pinyin", "code"], }} %>
class AutoCompleteUtil
  labelFields: []
  valueField: null
  source: []

  @setupAutoCompleteInput: (container) ->
    $(".ui-auto-complete", container).each (index, el) ->
      forAttr = $(el).attr("for")
      idEl = $("##{forAttr}") if forAttr
      ac = new AutoCompleteUtil
      ac.init(el) || console.log "AutoComplete init failed"
      $(el).autocomplete
        source: (request, callback)->
          ac.filter(request.term, callback)

        focus: (e, ui) ->
          $(el).val(ui.item.label)
          return false

        select: (e, ui) ->
          $(el).val(ui.item.label)
          if idEl
            idEl.val(ui.item.value)
          return false

      $(el).data("ui-autocomplete")._renderItem = (ul, item) ->
        text = item.label
        text += " " + item.label2 if item.label != item.label2 && item.label2
        return $("<li></li>").append("<a>#{text}</a>").appendTo(ul)

  init: (inputElement) ->
    if !inputElement
      console.log "input element null"
      return false

    source = $(inputElement).data("source")
    valueField = $(inputElement).data("value")
    labelFields = $(inputElement).data("labels")
    unless source && valueField && labelFields
      console.log "missing data attrs: source, value, labels"
      return false

    @valueField = valueField
    @labelFields = labelFields
    @source = source
    console.log "AutoComplete inited"
    return true

  filter: (term, callback) ->
    items = []
    #console.log @labelFields
    #console.log @source
    re = new RegExp("^" + $.ui.autocomplete.escapeRegex(term))
    self = @
    mainField = @labelFields[0]
    for item in @source
      for field in @labelFields
        if item[field].match(re)
          items.push
            "value": item[self.valueField]
            "label": item[mainField]
            "label2": item[field]
          break
    callback(items)

class TreeViewUtil
  # label:
  # id:
  # children: [...]
  @createData: (itemOrderList, opts) ->
    idField = opts.id
    parentIdField = opts.parent
    labelField = opts.label
    root =
      id: opts.rootId
      parent_id: null
      label: null
      children: []
    parents = [root]
    for item in itemOrderList
      item.id = item[idField]
      item.parent_id = item[parentIdField]
      item.children = []
      item.label = item[labelField]
      # find parent item
      # console.log "append item", item
      parent = null
      while node = parents.pop()
        if node.id == item.parent_id
          parent = node
          break
      if parent == null
        console.log "Invalid parent id error:", item
        return null
      else
        parents.push parent
        parents.push item
        parent.children.push item
    return root.children

$.util =
  createTreeData: (itemOrderList, opts) ->
    TreeViewUtil.createData(itemOrderList, opts)

  # <%= f.input :category_id, as: :tree, cmd: "do-something" %>
  # <%= tree_input_menu "do-something", tree_list_as_json %>
  # or, <%= category_menu "do-something" %>
  treeInput: (sel, container) ->
    $(sel, container).each (index, el) ->
      # make a patch to avoid auto complete confuse in UI
      $(el).attr("autocomplete", "off")
      cmdId = $(el).data("cmd")
      menu = root.cmdUI.findMenu(cmdId)
      # if menu not been found, then load menu from the tree-data
      if !menu
        tree = $(el).data("tree") ||
          $("div.ui-tree-input-menu[data-cmd='#{cmdId}']").data("tree")
        if tree
          menu = root.cmdUI.createMenu cmdId, tree,
            id: "code"
            parent: "parent_id"
            label: "name"
            rootId: null
            minInputLevel: $(el).data("min_input_level") || 0
      if menu == null
        console.log "cannot load menu: #{cmdId}"
        return false

      # install click handler
      $(el).click (e) ->
        e.stopPropagation()
        root.cmdUI.popupMenuSelect menu,
          right: this
          srcElement: this.id
      return true

  initCmdUI: () ->
    root.cmdUI.init()

  # usage
  #   class FooPage
  #     constructor: (action, _do) ->
  #       ...
  #
  #     # be called if no specified onLoad
  #     onLoad: () ->
  #
  #     onLoadActionDo: () ->
  #       ...
  #
  #   # export it
  #   root.FooPage = FooPage
  #
  # Reference:
  #   see plans.js.coffee
  onPageLoad: () ->
    pageId = $("body").attr("id")
    action = $("body").data("action")
    _do = $("body").data("do")
    pageClass = _.str.classify("#{pageId}_page")
    klass = root[pageClass]
    test = {}
    if klass && test.toString.call(klass) == "[object Function]"
      root.page = new klass(action, _do)
      if root.page
        @addCmdDelegate root.page
        fnName = _.str.camelize("on_load_#{action}_#{_do}")
        fn = root.page[fnName]
        if fn && test.toString.call(fn) == "[object Function]"
          fn.apply(root.page)
        else
          fn = root.page["onLoad"]
          if fn && test.toString.call(fn) == "[object Function]"
            # call onLoad
            fn.apply(root.page)
          else
            console.log "cannot find page load function: #{fnName}"
      else
        console.log "cannot create page object"
    else
      console.log "cannot find page class:", pageClass

  addCmdDelegate: (object) ->
    root.cmdUI.addDelegate(object)

  execCmd: (cmd, el) ->
    root.cmdUI.exec(cmd, el)

  popupMenu: (menuSel, el) ->
    root.cmdUI.popupMenu(menuSel, el)

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

  datepicker: (el) ->
    $(el).datepicker
      altFormat: "yy-mm-dd"     # rails want it
      dateFormat: "yy-mm-dd"    # just as rails set
      altField: $(el).next()
    # set as ISO 8601 at first, then modify to proper format: change initial display date
    dateFormat = $(el).data("opt-dateFormat") || "yy年mm月dd日 DD"
    $(el).datepicker("option", "dateFormat", dateFormat)
    $(el).datepicker($.datepicker.regional["zh-CN"])

  initUIGroupCheckbox: (container) ->
    $("input.ui-group-checkbox[type=checkbox]", container).each (_, cb) ->
      checked = $(cb).is(":checked")
      followers = $(cb).attr("for")
      $(cb).siblings(followers).each (_, el) ->
        $(el).attr("disabled", !checked)
      $(cb).click (e) ->
        checked = $(cb).is(":checked")
        $(cb).siblings(followers).each (_, el) ->
          $(el).attr("disabled", !checked)

  # simple usage:
  # $.util.init()
  init: (option, container) ->
    self = @
    if option
      fn = @initializors[option]
      if fn
        fn.call(self, container)
      else
        console.log "invalid option: #{option}"
        return false
    else
      for opt, fn of @initializors
        if opt.indexOf(":") < 0 && fn
          fn.call(self, container)
    return true

  initializors:
    "cmd-ui": (container) ->
      root.cmdUI.init(null, container)

    "cmd-ui:anchor": (container) ->
      root.cmdUI.init("cmd-ui:anchor", container)

    "cmd-ui:toolbar": (container) ->
      root.cmdUI.init("cmd-ui:toolbar", container)

    "cmd-ui:popup-menu": (container) ->
      root.cmdUI.init("cmd-ui:popup-menu", container)

    "alert-box": (container) ->
      $(".alert button.close", container).click () ->
        $(this).closest('.alert').remove()
      return true

    "datapicker": (container) ->
      self = $.util
      $("input.date.datepicker", container).each (index, el) ->
        self.datepicker el
      return true

    "ui-auto-complete": (container) ->
      AutoCompleteUtil.setupAutoCompleteInput(container)
      return true

    "ui-tree-input": (container) ->
      $.util.treeInput("input.ui-tree-input", container)
      return true

    "ui-selected-mark-collection": (container = "div.input.ui-selected-mark") ->
      $("span.checkbox input[type=checkbox].check_boxes:checked+label.collection_check_boxes",
        container).addClass("selected")
      return true

    # for("input.ui-group-checkbox[type=checkbox]"
    "ui-group-checkbox": (container) ->
      $.util.initUIGroupCheckbox(container)
      return true

#$->
# $.util.init()
# $.util.setupAutoCompleteInput(".ui-auto-complete")
# $.util.setupTreeInput("input.ui-tree-input")
# $.util.markCheckedCollectionItem("div.input.ui-selected-mark")
# $.util.setupUIGroupCheckbox("input.ui-group-checkbox[type=checkbox]")

