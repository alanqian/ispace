  id = <%= @store.id %>
  new_tr = "<%=j render partial: 'item', locals: { store: @store } %>"
  sel = "#stores-list tr[data-id=#{id}]"

<% if @store.errors.any? %>
  # show errors
  console.log "updating error!"
  refreshDataTr sel, new_tr, 'red'
<% else %>
  console.log "update ok."
  refreshDataTr sel, new_tr, 'green'
<% end %>
