# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
root = exports ? this

root.onProductCategoryChange = (event, el) ->
  form = $(el).closest("form.product")
  selDatas =
    "select#product_brand_id": "brand-id",
    "select#product_mfr_id": "mfr-id",
  for sel of selDatas
    select = form.find(sel)
    coll = $(el).data(selDatas[sel])[$(el).val()]
    console.log sel, coll
    select.find("option[value!='']").remove()
    select = form.find(sel)
    for id of coll
      select.append("<option value=#{id}>#{coll[id]}</option>")
  console.log "change category to", $(el).val()

root.onCancelSetup = (event, el) ->
  event.preventDefault()
  $(el).closest("form").closest("div").hide()

root.onClickSales = (event, el) ->
  event.preventDefault()
  inputName = "products[]"
  products = window.dataTableUtil.getSelection("table.dataTable", inputName)
  form = "form#products-setup-form"
  if products.length == 0
    alert("请先选择单品，再进行设置")
  else
    $(form).closest("div").show()

    # remove old selection
    $(form).find("input[name='#{inputName}']").remove()
    # setup new selection
    for id in products
      attrs =
        type: "hidden"
        id: "product__#{id}"
        name: inputName
        value: "#{id}"
      $('<input>').attr(attrs).appendTo(form)
    console.log "sale_type setup completed"
  return false

root.moveDivToRB = (div, el) ->
  posTo = $(el).offset()
  pos = $(div).offset()
  console.log "to:", posTo, $(el).width(), $(el).height()
  $(div).css
    left: posTo.left + $(el).width() - pos.left
    top: posTo.top + $(el).height() - pos.top
  console.log "new:", $(div).offset()

$ ->
  console.log "product start"
  $("form#new_product select#product_color").simplecolorpicker({picker: true})

  moveDivToRB("div.setup-container", "div#setup-place")
  $("#products-setup").hide()

