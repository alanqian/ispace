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

$ ->
  console.log "product start"
  $("form#new_product select#product_color").simplecolorpicker({picker: true})

