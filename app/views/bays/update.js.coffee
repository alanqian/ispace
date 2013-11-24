  id = <%= @bay.id %>
  new_tr = "<%=j render partial: 'item', locals: { bay: @bay } %>"
  sel = "#bays-list tr[data-id=#{id}]"

<% if @bay.errors.any? %>
  # show errors
  console.log "updating error!"
  refreshDataTr sel, new_tr, 'red'
<% else %>
  console.log "update ok."
  refreshDataTr sel, new_tr, 'green'
<% end %>
