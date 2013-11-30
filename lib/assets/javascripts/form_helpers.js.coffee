root = exports ? this

root.FormDataHelper = class FormDataHelper
  re: new RegExp("\\[([\\w\\d\_]+)\\]", "g")
  data: {}
  destroies: {}
  form: null

  constructor: (form) ->
    @form = form

  readInputs: () ->
    @data = {}
    @destroies = {}
    self = @
    $("#{@form} :input:not([type='submit']):not([type='button'])").each (_, el) ->
      self.updateInputValue(el)
      return true
    return @data

  updateInputValue: (el) ->
    fields = @getFields(el)
    attr = fields.pop()
    key = fields.join(".")
    return true if @destroies[key]?

    val = @getValue(el)
    if attr == "_destroy"
      if val == "1"  # hidden
        # remove the whole parent branch
        @destroies[key] = val
        attr = fields.pop()
        v = @data
        for field in fields
          if v[field]?
            v = v[field]
          else
            return true
        delete v.splice(attr, 1)
    else
      # initialize the section value to [] if undefined
      v = @data
      fields.push attr
      for i in [0...fields.length - 1] by 1 # skip the last attr
        field = fields[i]
        unless v[field]?
          if typeof(fields[i + 1]) == "number" # always exists
            v[field] = []
          else
            v[field] = {}
        v = v[field]
      # set node value
      v[attr] = val
    return true

  # $("form.simple_form.bay")
  getValue: (el) -> # el.value
    # normalize value
    if $(el).hasClass("decimal")
      val = parseFloat($(el).val()) || 0
    else if $(el).hasClass("integer")
      val = parseInt($(el).val()) || 0
    else if $(el).hasClass("color")
      val = $(el).val() || "#eeeeee"
    else if $(el).hasClass("string")
      val = $(el).val() || ""
    else if $(el).attr("type") == "checkbox"
      val = $(el).is(":checked") || false
    else if $(el).attr("type") == "hidden"
      val = $(el).val() || 0
    else
      console.log "unknown input: ", el
      val = $(el).val() || 0

  getFields: (el) -> # el.name
    # extract nested fields from input[name=]
    fields = []
    while m = @re.exec(el.name)
      field = m[1].replace("_attributes", "") # m[1] -> $1, ...
      field = parseInt(field) if field.match /^\d+$/
      fields.push field
    if fields.length == 0
      fields.push el.name
    else
      fields.unshift _.str.strLeft(el.name, "[")
    return fields

