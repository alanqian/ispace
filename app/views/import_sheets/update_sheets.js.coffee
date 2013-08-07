<% if @import_sheet.errors.any? %>
  step = <% @import_sheet.step %>
  errors = "<%= @import_sheet.errors.to_json %>"
  console.log("choose sheet failed, errors: #{errors}")
  # reload form with error messages
  html_src = "<%=j render partial: 'choose_sheets', locals: { import_sheet: @import_sheet, categories: Category.all } %>"
  window.importWizard.closePage("chooseSheets")
  $("#import-wizard").replaceWith(html_src)
  window.importWizard.openPage("chooseSheets")
  console.log("reload form with error messages")
<% else %>
  # choose_sheet success
  console.log("choose_sheet ok, file:<%= @import_sheet.filename %>, invoke map-field")

  if $("div#import-wizard").length == 0
    console.log "please add div#import-wizard to the body"
  else
    # close the old dialog
    window.importWizard.closePage("chooseSheets")
    window.importWizard.setId(<%= @import_sheet.id %>)
    # invoke the new dialog
    window.importWizard.openPage("mapFields")
    # initialize the mapping UI
    window.mapUtil.init()
<% end %>
