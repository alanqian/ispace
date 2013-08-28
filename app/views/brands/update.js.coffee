  # replace the modified record
  id = <%= @brand.id %>
  new_tr = "<%=j render partial: 'item', locals: { brand: @brand } %>"
  sel = "#brands-list tr[data-id=#{id}]"

<% if @brand.errors.any? %>
  # show errors
  console.log "updating error!"
  refreshDataTr sel, new_tr, 'red'
<% else %>
  console.log "update ok."
  refreshDataTr sel, new_tr, 'green'
<% end %>
