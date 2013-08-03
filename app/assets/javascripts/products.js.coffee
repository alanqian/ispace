# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
root = exports ? this

root.autoMapping = (event,el) =>
  event.preventDefault()
  console.log "auto mapping by ", el, $(el).data('src')
  mapping = $(el).data('src')
  mappingAuto(mapping)

$ ->
  $('#new_import_sheet').bind('ajax:success', (event, data, status, xhr) ->
    console.log "ajax success new_import_sheet"
    console.log data
  ).bind("ajax:error", (evt, xhr, status, error) ->
    console.log "ajax error"
    console.log status, error
    console.log xhr
  )

  console.log "set ajax ok"

  root.mappingAuto = (mapping) ->
    # clear old mappings
    $('td.mapping-input').each (idx) ->
      mappingClearToValue $(this).parent()
    $('.mapping-to-fields li').each (idx) ->
      mappingUncheckToElement this

    # set auto mappings
    $('td.mapping-input').each (idx) ->
      name = $(this).data('field')
      to = mapping[name]
      console.log "enum mapping-input td,", name, to
      return unless to

      tr = $(this).parent()
      elTo = $("li[data-field*='#{to}']").get(0)
      if tr && elTo
        mappingSetActiveRow tr
        mappingClickToElement elTo
    return false;

  mappingSetActiveRow = (tr) ->
    if window.field_mapping.activeRow != null
      $(window.field_mapping.activeRow).children('td').removeClass('active')
    if tr != null
      $(tr).children('td').addClass('active')
      scrollIntoView(tr)
    window.field_mapping.activeRow = tr
    if tr.data('to')
      mappingSetActiveToElement tr.data('to')
    console.log "current mapping: ", tr.data('to'), tr

  root.test = () ->
    console.log "test only!"

  scrollIntoView = (el) ->
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

  noDataTo = () ->
    ! $(this).data('to')

  mappingSetActiveNext = () ->
    if window.field_mapping.activeRow == null
      # first row w/o data
      tr = $('.mapping-src tr').filter(noDataTo).first()
      # first row
      if tr.length == 0
        tr = $('.mapping-src tr:first')
    else
      # next row w/o data-to
      tr = $(window.field_mapping.activeRow).nextAll('tr').filter(noDataTo).first()
      # first row of table w/o data-to
      if tr.length == 0
        tr = $('.mapping-src tr').filter(noDataTo).first()
      # next row
      if tr.length == 0
        tr = $(window.field_mapping.activeRow).next('tr')
      # first row
      if tr.length == 0
        tr = $('.mapping-src tr:first')

    console.log "next no-data tr", tr
    mappingSetActiveRow tr

  mappingSetToValue = (li) ->
    if window.field_mapping.activeRow != null
      tr = window.field_mapping.activeRow
      td = $(tr).children('td').eq(1) # the 2nd td
      value = $(li).data('field')
      $(td).children('input').val(value)
      label = $(li).text()
      $(td).children('span').text(label)
      # set mapping link, src <-> dest
      if $(tr).data('to')
        mappingUncheckToElement($(tr).data('to'))
      mappingCheckToElement(li, tr)
      $(tr).data('to', li)

  mappingClearToValue = (tr) ->
    if tr != null
      td = $(tr).children('td').eq(1) # the 2nd td
      $(td).children('input').val(null)
      $(td).children('span').text('')
      tr.removeData('to')

  mappingCheckToElement = (el, src) ->
    console.log "checked, ", el, src
    $(el).addClass('checked')
    $(el).data('to', src)

  mappingUncheckToElement = (el) ->
    console.log "unchecked, ", el
    $(el).removeClass('checked')
    $(el).removeData('to')

  mappingSetActiveToElement = (el) ->
    oldTo = window.field_mapping.activeTo
    if oldTo != el
      if oldTo != null
        $(oldTo).removeClass("active")
      if el != null
        $(el).addClass("active")
      window.field_mapping.activeTo = el
    if el != null
      scrollIntoView(el)
    console.log "current mapping: ", $(el).data('to'), el

  mappingClickToElement = (el) ->
    # set active item
    mappingSetActiveToElement(el)

    # do mapping
    if $(el).data('to')
      console.log "has been mapped to", $(el).data('to')
      to = $(el).data('to')
      if to == window.field_mapping.activeRow
        mappingClearToValue(to)
        mappingUncheckToElement(el)
      else
        mappingSetActiveRow to
    else
      to = window.field_mapping.activeRow
      if to
        console.log "to be mapped to", $(to)
        mappingSetToValue(el)
        mappingSetActiveNext()
        mappingSetActiveToElement null
      else
        console.log "no select src field, select this item only"

  test = (tr) ->
    console.log "map source row selected: ", tr

    # set selected row
    $(tr).children('td').addClass('active')

    td = $(tr).children('td').eq(1) # the 2nd td

    input = $(td).children('input')
    span = $(td).children('span')
    console.log input, span

  $('ul.mapping-to-fields li').click ->
    console.log "li clicked: ", $(this).text(), $(this).data('field')
    mappingClickToElement(this)

  $('td.mapping-name').click ->
    console.log "mapping-name td clicked!"
    mappingSetActiveRow($(this).parent())

  $('td.mapping-input').click ->
    console.log "mapping-input td clicked!"
    mappingSetActiveRow($(this).parent())

