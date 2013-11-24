# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
root = exports ? this

class ProductPage
  action: ""
  _do: ""

  constructor: (action, _do) ->
    console.log "create PlanPage"
    @action = action
    @_do = _do

  onLoad: () ->
    $("form#new_product select#product_color").simplecolorpicker
      picker: true
    return true

  onCategoryChanged: (el) ->
    id = $(el).val()
    url = $(el).data("url")
    # only for index page, the input element has data url
    if url && id
      window.location = url + id
    return true

  onSelectProductsGrade: (el) ->
    if @validateSelection()
      $.util.popupMenu "#select-products-grade-menu",
        under: el
    return true

  onSetProductsGrade: (el) ->
    grade = $(el).data("grade")
    console.log "set grade to #{grade}"
    form = $("form#products-set-grade-form")
    if !@validateSelection(form)
      console.log "invalid selection"
    else
      @fillInputs form,
        sale_type: grade
      form.submit()
    return true

  onSelectProductsOnSale: (el) ->
    if @validateSelection()
      $.util.popupMenu "#select-products-on-sale-menu",
        under: el
    return true

  onSetProductsOnSale: (el) ->
    new_product = $(el).data("new_product")
    on_promotion = $(el).data("on_promotion")
    console.log "set product to new:#{new_product}, pro:#{on_promotion}"
    form = $("form#products-set-on-sale-form")
    # form: input
    # form.submit
    if !@validateSelection()
      console.log "invalid selection"
    else
      @fillInputs form,
        new_product: new_product
        on_promotion: on_promotion
      form.submit()
    return true

  fillInputs: (form, inputs) ->
    for attr, value of inputs
      $("input[name='product[#{attr}]']", form).val(value)
    return true

  validateSelection: (form) ->
    inputName = "products[]"
    products = root.dataTableUtil.getSelection("table.dataTable", inputName)
    if products.length == 0
      alert("请先选择单品，再进行设置")
      return false
    else
      if form # update form inputs
        inputs = $("input[name='products[]']", form)
        # extract input template
        tmpl = inputs.first().clone()
        # clear all old selections
        $("input[name='products[]']", form).remove()
        # add selections to input value
        for id in products
          input = tmpl.clone().val(id)
          form.append(input)
        # remove template
        tmpl.remove()
      return true

root.ProductPage = ProductPage
