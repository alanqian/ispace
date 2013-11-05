  id = <%= @user.id %>
  new_tr = "<%=j render partial: 'item', locals: { user: @user } %>"
  sel = "#users-list tr[data-id=#{id}]"

<% if @user.errors.any? %>
  # show errors
  console.log "updating error!"
  refreshDataTr sel, new_tr, 'red'
<% else %>
  console.log "update ok."
  refreshDataTr sel, new_tr, 'green'
<% end %>
