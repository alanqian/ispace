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

  @setupAutoCompleteInput: (sel = ".auto-complete") ->
    $(sel).each (index, el) ->
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

  setupAutoCompleteInput: (sel) ->
    AutoCompleteUtil.setupAutoCompleteInput(sel)

  # <%= f.input :category_name, input_html: { class: "ui-tree-input",
  #   data: {
  #     cmd: "select-category",
  #     tree: @categories_all.to_json
  #   } %>
  setupTreeInput: (sel) ->
    $(sel).each (index, el) ->
      $(el).attr("autocomplete", "off")
      menu = root.cmdUI.createMenu $(el).data("cmd"), $(el).data("tree"),
        id: "code"
        parent: "parent_id"
        label: "name"
        rootId: null
        dom: "body"
        srcElement: el.id
      $(el).data("uiTreeMenu", menu)
      $(el).click (e) ->
        e.stopPropagation()
        menu = $(this).data("uiTreeMenu")
        root.cmdUI.popupMenuSelect menu,
          right: this

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

  markCheckedCollectionItem: (inputDiv) ->
    $("span.checkbox input[type=checkbox].check_boxes:checked+label.collection_check_boxes",
      inputDiv).addClass("selected")

  datepicker: (el) ->
    $(el).datepicker
      altFormat: "yy-mm-dd"     # rails want it
      dateFormat: "yy-mm-dd"    # just as rails set
      altField: $(el).next()
    # set as ISO 8601 at first, then modify to proper format: change initial display date
    dateFormat = $(el).data("opt-dateFormat") || "yy年mm月dd日 DD"
    $(el).datepicker("option", "dateFormat", dateFormat)
    $(el).datepicker($.datepicker.regional["zh-CN"])

  setupDatePicker: () ->
    self = @
    $("input.date.datepicker").each (index, el) ->
      self.datepicker el

  setupUIGroupCheckbox: (checkbox_sel) ->
    $(checkbox_sel).each (_, cb) ->
      checked = $(cb).is(":checked")
      followers = $(cb).attr("for")
      $(cb).siblings(followers).each (_, el) ->
        $(el).attr("disabled", !checked)
      $(cb).click (e) ->
        checked = $(cb).is(":checked")
        $(cb).siblings(followers).each (_, el) ->
          $(el).attr("disabled", !checked)

$ ->
  $.util.initCmdUI()
  $.util.setupDatePicker()
  $.util.setupAutoCompleteInput(".ui-auto-complete")
  $.util.setupTreeInput("input.ui-tree-input")
  $.util.markCheckedCollectionItem("div.input.ui-selected-mark")
  $.util.setupUIGroupCheckbox("input.ui-group-checkbox[type=checkbox]")

