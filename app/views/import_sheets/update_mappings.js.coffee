<% if @import_sheet.errors.any? %>
  step = <% @import_sheet.step %>
  errors = "<%= @import_sheet.errors.to_json %>"
  console.log("mapping fields failed, errors: #{errors}")
  # reload form with error messages
  html_src = "<%=j render partial:'map_fields', locals: { import_sheet: @import_sheet, to_fields: ImportSheet.mapping_fields, auto_mapping: ImportSheet.auto_mapping  } %>"
  window.importWizard.closePage("mapFields")
  $("#new_import_sheet").replaceWith(html_src)
  window.importWizard.openPage("mapFields")
  console.log("reload form with error messages")
<% else %>
  # mapping_fields success
  console.log("mapping fields ok, file:<%= @import_sheet.filename %>, show imported")
  window.importWizard.closePage("mapFields")
<% end %>
