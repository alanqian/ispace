  id = <%= @fixture.id %>
  new_tr = "<%=j render partial: 'item', locals: { fixture: @fixture } %>"
  sel = "#fixtures-list tr[data-id=#{id}]"

<% if @fixture.errors.any? %>
  # show errors
  console.log "updating error!"
  refreshDataTr sel, new_tr, 'red'
<% else %>
  console.log "update ok."
  refreshDataTr sel, new_tr, 'green'
<% end %>
