# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
root = exports ? this

class InplaceEditor
  table: null
  inputs: null
  form: null
  div: null
  url: null
  activeRow: null

  init: (table) ->
    self = @
    @form = $(table).data("form")
    @div = $(".inputs", @form)
    @url = $(@form).data("url")
    @inputs = []
    $("thead tr th", table).each (index, th) ->
      # input = $("input[name='#{el}'] ")
      sel = null
      if sel = $(th).data("input")
        self.inputs.push "input[name='#{sel}']"
      else if sel = $(th).data("select")
        self.inputs.push "select[name='#{sel}']"
      else
        self.inputs.push undefined

    console.log @inputs
    @table = table

    # td.onclick handler
    $(table).on "click", "tbody tr td", (event) ->
      self.bind($(this).parent())

    return self

  inputIntoTd: (input, td) ->
    # modify input size, and move into td
    if input.attr("type") == "text"
      input.css("width", "98%")
      input.css("height", "99%")
    td.wrapInner("<span class='hide'>")
    input.appendTo(td)

  initInputVal: (input, td) ->
    if input.prop("tagName") == "SELECT"
      val = td.data("val") || td.text()
    else if input.prop("tagName") == "INPUT"
      if input.attr("type") == "checkbox"
        val = td.data("val")
        input.prop("checked", val)
      else
        if td.data("val")
          input.val(td.data("val"))
        else
          input.val(td.text())

  inputOutOfTd: (td, div) ->
    input = $("input", td)
    input.appendTo(div)
    $("span", td).contents().unwrap()

  onBlur: (input) ->
    if isBinded(input)
      console.log "unbind input, ignored", input
      return false

    el = document.activeElement
    if el.tagName != "INPUT" && el.tagName != "SELECT"
      # unbind and ...
      @unbind()
    else if $(el).closet("form")[0] == $(@form)[0]
      # inputs of same form, do nothing
      console.log "same form"
    else
      @unbind()

  isBinded: (input) ->
    td = input.parent()
    if td.prop("tagName") != "TD"
      return false
    else
      return true

  unbind: ()->
    console.log "ajax submit..."
    self = @
    if @activeRow != null
      # move inputs out of td
      tds = $("td", @activeRow)
      @inputs.forEach (sel, index) ->
        if sel
          self.inputOutOfTd(tds.eq(index), self.div)
      # submit form
      # $(@form).submit()

    @activeRow = null # reset active row

  bind: (tr) ->
    self = @
    if !@table
      console.log "uninited editor"
      return false
    if tr.parent().parent()[0] != @table
      console.log "unbinded tr!"
      return false

    # check active row, unbind if different row
    if @activeRow == tr[0]
      console.log "same row, return"
      return true
    else
      console.log "click another row, unbind old"
      @unbind()

    # set action attr of the form
    id = tr.data("id")
    if !id
      console.log "error: no id for tr element"
      return false
    else
      console.log "new action:", @url + id, $(@form)[0]
      $(@form).attr("action", @url + id)

    # move relative INPUT into td
    tds = $("td", tr)
    @inputs.forEach (sel, index) ->
      if sel
        input = $(sel)
        console.log "binding td", index, sel, tds[index], input[0]
        self.initInputVal(input, tds.eq(index))
        self.inputIntoTd(input, tds.eq(index))
    # console.log "bind tr", tr
    @activeRow = tr[0]

$ ->
  console.log "brands.js start"
  # inplace-edit init
  window.editor = null
  $("table.dataTable[data-form]").each (index, table) ->
    console.log index, $(table)
    editor =  new InplaceEditor
    editor.init(table)
    table.editor = editor
    window.editor = editor # for debug only

