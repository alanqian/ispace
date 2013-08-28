  # replace the modified record
  id = <%= @supplier.id %>
  new_tr = "<%=j render partial: 'item', locals: { supplier: @supplier } %>"
  sel = "#suppliers-list tr[data-id=#{id}]"

<% if @supplier.errors.any? %>
  # show errors
  console.log "updating error!"
  refreshDataTr sel, new_tr, 'red'
<% else %>
  console.log "update ok."
  refreshDataTr sel, new_tr, 'green'
<% end %>
