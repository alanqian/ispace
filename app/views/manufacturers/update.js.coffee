  # replace the modified record
  id = <%= @manufacturer.id %>
  new_tr = "<%=j render partial: 'item', locals: { manufacturer: @manufacturer } %>"
  sel = "#manufacturers-list tr[data-id=#{id}]"

<% if @manufacturer.errors.any? %>
  # show errors
  console.log "updating error!"
  refreshDataTr sel, new_tr, 'red'
<% else %>
  console.log "update ok."
  refreshDataTr sel, new_tr, 'green'
<% end %>
