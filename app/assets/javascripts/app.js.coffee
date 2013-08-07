root = exports ? this

root.foo = () ->
  console.log "foo"

root.mapUtil =
  activeRow: null
  activeTo: null
  init: () ->
    self = @
    $('ul.mapping-to-fields li').click ->
      console.log "li clicked: ", $(this).text(), $(this).data('field')
      self.clickToElement(this)

    $('td.mapping-name').click ->
      console.log "mapping-name td clicked!"
      self.setActiveRow($(this).parent())

    $('td.mapping-input').click ->
      console.log "mapping-input td clicked!"
      self.setActiveRow($(this).parent())
    console.log "mapping-input ui init'd!"

  autoMapping: (event,el) ->
    event.preventDefault()
    console.log "auto mapping by ", el, $(el).data('src')
    mapping = $(el).data('src')
    @doMapping(mapping)
    return false

  doMapping: (mapping) ->
    # clear old mappings
    self = @
    $('td.mapping-input').each (idx) ->
      self.clearToValue $(this).parent()
    $('.mapping-to-fields li').each (idx) ->
      self.uncheckToElement this

    # set auto mappings
    $('td.mapping-input').each (idx) ->
      name = $(this).data('field')
      to = mapping[name]
      console.log "enum mapping-input td,", name, to
      return unless to

      tr = $(this).parent()
      elTo = $("li[data-field*='#{to}']").get(0)
      if tr && elTo
        self.setActiveRow tr
        self.clickToElement elTo

  setActiveRow: (tr) ->
    if @activeRow != null
      $(@activeRow).children('td').removeClass('active')
    if tr != null
      $(tr).children('td').addClass('active')
      @scrollIntoView(tr)
    @activeRow = tr
    if tr.data('to')
      @setActiveToElement tr.data('to')
    console.log "current mapping: ", tr.data('to'), tr

  scrollIntoView: (el) ->
    container = $(el).closest("div")
    containerTop = $(container).position().top
    containerBottom = containerTop + $(container).height()

    elemTop = $(el).position().top
    elemBottom = elemTop + $(el).height()

    scrollBy = container.scrollTop()

    if elemTop - scrollBy < containerTop
      # scrollTo elemTop
      $(container).scrollTop(elemTop - containerTop)
    else if elemBottom - scrollBy > containerBottom
      # scrollTo elemBottom
      $(container).scrollTop(elemBottom - containerBottom)
    else
      # visible, do nothing
      # console.log "visible:", el, elemTop, elemBottom, "container", containerTop, containerBottom

  hasNoDataTo: (index) ->
    ! $.data(this, 'to')  # w/o data-to

  setActiveNext: () ->
    if @activeRow == null
      # first row w/o data
      tr = $('.mapping-src tr').filter(@hasNoDataTo).first()
      # first row
      if tr.length == 0
        tr = $('.mapping-src tr:first')
    else
      # next row w/o data-to
      tr = $(@activeRow).nextAll('tr').filter(@hasNoDataTo).first()
      # first row of table w/o data-to
      if tr.length == 0
        tr = $('.mapping-src tr').filter(@hasNoDataTo).first()
      # next row
      if tr.length == 0
        tr = $(@activeRow).next('tr')
      # first row
      if tr.length == 0
        tr = $('.mapping-src tr:first')

    console.log "next no-data tr", tr
    @setActiveRow tr

  setToValue: (li) ->
    if @activeRow != null
      tr = @activeRow
      td = $(tr).children('td').eq(1) # the 2nd td
      value = $(li).data('field')
      $(td).children('input').val(value)
      label = $(li).text()
      $(td).children('span').text(label)
      # set mapping link, src <-> dest
      if $(tr).data('to')
        @uncheckToElement($(tr).data('to'))
      @checkToElement(li, tr)
      $(tr).data('to', li)

  clearToValue: (tr) ->
    if tr != null
      td = $(tr).children('td').eq(1) # the 2nd td
      $(td).children('input').val(null)
      $(td).children('span').text('')
      tr.removeData('to')

  checkToElement: (el, src) ->
    console.log "checked, ", el, src
    $(el).addClass('checked')
    $(el).data('to', src)

  uncheckToElement: (el) ->
    console.log "unchecked, ", el
    $(el).removeClass('checked')
    $(el).removeData('to')

  setActiveToElement: (el) ->
    oldTo = @activeTo
    if oldTo != el
      if oldTo != null
        $(oldTo).removeClass("active")
      if el != null
        $(el).addClass("active")
      @activeTo = el
    if el != null
      @scrollIntoView(el)
    console.log "current mapping: ", $(el).data('to'), el

  clickToElement:  (el) ->
    # set active item
    @setActiveToElement(el)

    # do mapping
    if $(el).data('to')
      console.log "has been mapped to", $(el).data('to')
      to = $(el).data('to')
      if to == @activeRow
        @clearToValue(to)
        @uncheckToElement(el)
      else
        @setActiveRow to
    else
      to = @activeRow
      if to
        console.log "to be mapped to", $(to)
        @setToValue(el)
        @setActiveNext()
        @setActiveToElement null
      else
        console.log "no select src field, select this item only"

root.importWizard =
  inited: false
  id: 0
  common:
    selector: "div#import-wizard"
    width: "420px"
    height: "520px"
  upload:
    url: "/import_sheets/new?ajax=1"
    prev: null # wizard object for prev step
    cancel: null # function called when canceled
    finish: null # function called when finished, must set if no given url
    debug: true
  chooseSheets:
    url: "/import_sheets/#{@id}/edit?ajax=chooseSheets"
    prev: null # window.importWizard.upload
    cancel: null # function called when canceled
    finish: null # function called when finished, must set if no given url
    debug: true
  mapFields:
    url: "/import_sheets/#{@id}/edit?ajax=mapFields"
    prev: @chooseSheets # window.importWizard.chooseSheets
    cancel: null # function called when canceled
    width: 430
    finish: () -> # function called when finished, must set if no given url
      console.log "import product sheet file completed!"
    debug: true
  clearImport: () ->
    if @id && @id > 0
      url = "/import_sheets/#{@id}"
      $.ajax
        url: url
        type: 'DELETE'
        error: () ->
          if wizard.debug
            console.log "..ajax error, DELETE #{url}"
        success: (data, textStatus, jqXHR) ->
          if wizard.debug
            console.log "..ajax success, DELETE #{url}"
        complete: (jqXHR) ->
          if wizard.debug
            console.log "..ajax complete, DELETE #{url}"
  setId: (id) ->
    if id
      @id = id
      @chooseSheets.url = "/import_sheets/#{@id}/edit?ajax=chooseSheets"
      @mapFields.url = "/import_sheets/#{@id}/edit?ajax=mapFields"
  init: () ->
    if !@inited
      [@upload, @chooseSheets, @mapFields].map (wizard) =>
        wizard.selector = @common.selector
        wizard.cancel = @clearImport unless wizard.cancel
      @chooseSheets.prev = @upload
      @mapFields.prev = @chooseSheets
      @inited = true
  openPage: (page) ->
    if this[page] && this[page].url
      @init()
      return root.showWizard(this[page])
    else
      console.log "cannot find page in this wizard, page:#{page}"
      return false
  closePage: (page) ->
    if this[page] && this[page].close
      this[page].close()

root.showWizard = (wizard) ->
  wizard.close = () ->
    wizard.disableCancel = true
    $(@selector).dialog('close')
    delete this.close

  wizard.invoke = () ->
    # setup buttons
    # cancel.click -> simply close dialog
    # next.click -> default ajax submit
    $("#{@selector} input[type='submit'][data-wizard-action='cancel']").click (event) =>
      event.preventDefault()
      $(@selector).dialog("close")

    $("#{@selector} input[type='submit'][data-wizard-action='prev']").click (event) =>
      event.preventDefault()
      wizard.disableCancel = true
      $(@selector).dialog("close")
      # show form of prev step
      if @prev
        showWizard(@prev)

    $(@selector).hide()
    $(@selector).dialog
      minWidth: 430
      minHeight: 220
      close: (event, ui) =>
        console.log "wizard dialog closed, then destroy", event
        if @cancel && !wizard.disableCancel
          @cancel()
          delete wizard.disableCancel
        $(@selector).dialog('destroy')

  if $(wizard.selector).length == 0
    console.log "please add #{selector} to the body"
    return

  if wizard.url
    # make ajax call to get the form code
    $.ajax
      url: wizard.url
      error: () ->
        if wizard.debug
          console.log "..ajax error, #{wizard.url}"
      complete: (jqXHR) ->
        if wizard.debug
          console.log "..ajax complete, #{wizard.url}"
      success: (data, textStatus, jqXHR) ->
        if wizard.debug
          console.log "..ajax success, #{wizard.url}"

        # replace html of wizard container
        $(wizard.selector).replaceWith(data)
        console.log "..import replaced"
        wizard.invoke()
        console.log "..dialog show"
  else if wizard.finish
    console.log "wizard finished"
    wizard.finish()
  else
    console.log "wizard: must set one of the member of url/finish"
  return $(wizard.selector)

  if $("div#import-wizard").length > 0
    console.log "importWizard start..."
    $.ajax
      url: "/import_sheets/new?ajax=1",
      error: () ->
        console.log "..ajax error"
      complete: (jqXHR) ->
        console.log "..ajax complete"
      success: (data, textStatus, jqXHR) ->
        console.log "..ajax success"
        # console.log htmlSrc
        $("div#import-wizard").replaceWith(data)
        console.log "..import replaced"
        wizardProc("div#import-wizard")
        console.log "..dialog show"
  else
    console.log "please add div#import-wizard to the body"

root.wizardProc = (jq_sel) ->
  # setup buttons
  # cancel.click -> simply close dialog
  # next.click -> default ajax submit
  $("#{jq_sel} input[type='submit'][data-wizard-action='cancel']").click (event) ->
    event.preventDefault()
    $(jq_sel).dialog("close")

  $(jq_sel).width("600px")
  $(jq_sel).dialog
    close: ->
      console.log "close wizard dialog, then destroy"
      $("div#import-wizard").dialog('destroy')

root.setSheetUI = () ->
  $("table.resizable").colResizable({
    liveDrag: true,
    gripInnerHtml: "<div class='grip'></div>",
    draggingClass: "dragging",
    onResize: null})

  $("div.tabs").tabs(
    activate: (event, ui) ->
      console.log "activate:", ui.newPanel.selector
      window.location.hash = ui.newPanel.selector
  )
  if $("div.tabs-bottom").length > 0
    console.log "fixing tabs in bottom"
    # fix the classes
    $("div.tabs-bottom ul").removeClass("ui-hidden")
    $( ".tabs-bottom .ui-tabs-nav, .tabs-bottom .ui-tabs-nav > *" )
      .removeClass( "ui-corner-all ui-corner-top" )
      .addClass( "ui-corner-bottom" )
    # move the nav to the bottom
    $( ".tabs-bottom .ui-tabs-nav" ).appendTo( ".tabs-bottom" )

  # set bgcolor of first column of a spreadsheet
  bgcolor = $(".ui-widget-header").css("background-color")
  $("td:first", $("table.grid-control tbody tr")).css("background-color",
    bgcolor).css("text-align", "center")


$ ->
  console.log "loading common components..."
  # $.ajaxSettings.dataType = "json"
  $("#menubar").menu({ position: { my: "left top", at: "left-1 top+35" } })
  $("table.dataTable").dataTable({
    "aaSorting": [[ 4, "desc" ]],
    "bJQueryUI": true,
    "aLengthMenu": [[5, 10, 15, 25, 50, -1], [5, 10, 15, 25, 50, "All"]],
    "iDisplayLength": 10,
    'bLengthChange': false,
    #"sScrollY": calcDataTableHeight(), don't use, it will split to two tables
    #"sPaginationType": "full_numbers",
    # length-change, info, pagination, filtering input
    # dataTables_length
    # dataTables_info
    # dataTables_paginate
    # dataTables_filter
    "sDom": '<"top"ipf>rt<"clear">',
    "oLanguage": {
        "sProcessing":   "处理中...",
        "sLengthMenu":   "每页显示 _MENU_ 条，",
        "sZeroRecords":  "没有匹配结果",
        "sInfo":         "_START_ - _END_，共 _TOTAL_ 条",
        "sInfoEmpty":    "无结果，请重新搜索",
        "sInfoFiltered": "&#47; _MAX_ 条",
        "sInfoPostFix":  "",
        "sSearch":       "搜索:",
        "sUrl":          "",
        "oPaginate": {
            "sFirst":    "首页",
            "sPrevious": "上页",
            "sNext":     "下页",
            "sLast":     "末页"
        }
    }})

  # resizable, tabs, tabs-bottom, ...
  setSheetUI()
  $("div.accordion").accordion()
  console.log "common components loaded"

