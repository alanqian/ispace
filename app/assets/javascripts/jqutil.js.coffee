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

$.util =
  initCmdUI: () ->
    root.cmdUI.init()

  addCmdDelegate: (object) ->
    root.cmdUI.addDelegate(object)

  setupAutoCompleteInput: (sel) ->
    AutoCompleteUtil.setupAutoCompleteInput(sel)

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

$ ->
  $.util.initCmdUI()
  $.util.setupAutoCompleteInput(".auto-complete")

