# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
root = exports ? this

class InplaceEditor
  debug: false
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
      if @debug
        console.log @inputs

    @table = table

    # td.onclick handler
    $(table).on "click", "tbody tr td", (event) ->
      self.bind($(this).parent(), this, event.target)

    return self

  initInputVal: (input, td) ->
    if input.prop("tagName") == "SELECT"
      val = td.data("val") || td.text()
      input.val(val)
    else if input.prop("tagName") == "INPUT"
      if input.attr("type") == "checkbox"
        val = td.data("val")
        input.prop("checked", val)
      else
        if td.data("val")
          input.val(td.data("val"))
        else
          input.val(td.text())

  inputIntoTd: (input, td) ->
    # modify input size, and move into td
    if input.attr("type") == "text"
      input.css("width", "98%")
      input.css("height", "99%")
    td.wrapInner("<span class='hide'>")
    input = input.appendTo(td)
    # patch for jquery simplecolorpicker
    if @debug
      console.log "into td:", input
    if input.hasClass("colorpicker")
      input.simplecolorpicker({picker: true})

  inputOutOfTd: (td, div) ->
    input = $("input,select", td)
    # patch for jquery simplecolorpicker
    if input.hasClass("colorpicker")
      input.simplecolorpicker("destroy")
    input.appendTo(div)
    $(">span.hide", td).contents().unwrap()

  onblurInput: (event) ->
    picking = false
    el = event.target
    if $(el).prop("blurBy")
      rel = $(el).prop("blurBy")
      picking = $(el).prop("picking")
    else
      rel = event.relatedTarget
    console.log "onblur:", event, el, rel

    if !@isParentTD(el)
      console.log "unbind input, ignored.", rel, el, el.parentElement
      return false
    if el.parentElement == rel
      console.log "blur by same td, ignored.", el, rel
      return false

    # find who will get focus
    input = $(el)
    relOb = @getInputOb(rel)
    if relOb == null
      rel = document.activeElement
    else
      rel = relOb[0]
    console.log ">focus rel=", rel

    if rel.tagName != "INPUT" && rel.tagName != "SELECT"
      # user click out of inputs, submit it
      console.log "@unbind, focus to", rel
      @unbind()
    else if $(rel).closest("form")[0] == $(@form)[0]
      # click input els of same form, do nothing
      console.log "do nothing, input of same form"
    else
      # click input els of other form, submit
      console.log "unbind: input of other form"
      @unbind()

  getInputOb: (el) ->
    if el
      if el.tagName == "INPUT" || el.tagName == "SELECT"
        return $(el)

      # make a patch for simple color picker
      if el.tagName == "SPAN" &&
        $(el).hasClass("simplecolorpicker") &&
        $(el).hasClass("icon")
          return $(el).prev('select')
    return null

  isParentTD: (el) ->
    el.parentElement.tagName == "TD"

  unbind: ()->
    console.log "unbinding..."
    self = @
    if @activeRow != null
      # move inputs out of td
      tds = $("td", @activeRow)
      @inputs.forEach (sel, index) ->
        if sel
          self.inputOutOfTd(tds.eq(index), self.div)
      # submit form
      console.log "ajax submit ", $(@form).attr("action")
      $(@form).submit()

    @activeRow = null # reset active row

  bind: (tr, td, target) ->
    self = @
    if !@table
      console.log "uninited editor"
      return false
    if tr.parent().parent()[0] != @table
      console.log "unbinded tr!"
      return false

    # check active row, unbind if different row
    if @activeRow == tr[0]
      if @debug
        console.log "same row, return"
      return true
    else
      if @debug
        console.log "click another row, unbind old"
      @unbind()

    # set action attr of the form
    id = tr.data("id")
    if !id
      console.log "error: no id for tr element"
      return false
    else
      console.log "binding set new action:", @url + id, $(@form)[0]
      $(@form).attr("action", @url + id)

    # move relative INPUT into td
    tds = $("td", tr)
    @inputs.forEach (sel, index) ->
      if sel
        input = $(sel)
        if @debug
          console.log "binding td", index, sel, tds[index], input[0]
        self.initInputVal(input, tds.eq(index))
        self.inputIntoTd(input, tds.eq(index))
        $(sel).blur (e) ->
          self.onblurInput(e)

    if @debug
      console.log "bind tr", tr
    @activeRow = tr[0]

    # click it if td is a colorpicker field
    if target.tagName == "SPAN" && $(target).hasClass("colorbox")
      $(">span.simplecolorpicker.icon", td).click()

$ ->
  console.log "brands.js start"
  # inplace-edit init
  window.editor = null
  $("table.dataTable[data-form]").each (index, table) ->
    # console.log index, $(table)
    editor =  new InplaceEditor
    editor.init(table)
    table.editor = editor
    window.editor = editor # for debug only

  # notes for simple color picker
  # $('select.colorpicker').simplecolorpicker({picker: true})
  # simplecolorpicker("destroy")

