<% if @import_sheet.errors.any? %>
  errors = "<%= @import_sheet.errors.to_json %>"
  console.log("upload failed, errors: #{errors}")

  # reload form with error messages
  html_src = "<%=j render partial:'upload', locals: { import_sheet: @import_sheet } %>"
  $("#new_import_sheet").replaceWith(html_src)
  console.log("reload form with error messages")
<% else %>
  console.log("uploaded spreadsheet file <%= @import_sheet.filename %> ok, invoke chooseSheets")

  if $("div#import-wizard").length == 0
    console.log "please add div#import-wizard to the body"
  else
    # close the old dialog
    window.importWizard.closePage("upload")
    window.importWizard.setId(<%= @import_sheet.id %>)
    # invoke the chooseSheets dialog
    console.log "invoke chooseSheets"
    window.importWizard.openPage("chooseSheets")
<% end %>

#####################################################
# check file upload is required:
#   $("#import_sheet_upload_sheet").val()
#   $("input.required[type=file]").val()

# TODO:
# if success:
#   show wizard(step 2): select sheets of uploaded file;
#   show preview part of the sheet file
# else
#   show errors in this step of wizard

# select sheets:
# if success:
#   show wizard(step 3): show sheet
#   show preview part of the sheet file

# set mapping sheets:
# when mapping, show "waiting..." message
# if success:
#   stop "waiting"
#   close wizard dialog
#   show import results;
#   imported brands, manufacturers, suppliers;
#   imported products, mdses;
#   show all aboves with links;
# else
#   stop "waiting"
#   show errors, reset the mapping;
