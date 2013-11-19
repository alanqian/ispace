  id = "<%= @category.id %>"
  new_tr = "<%=j render partial: 'item', locals: { category: @category } %>"
  sel = "#categories-list tr[data-id=#{id}]"

<% if @category.errors.any? %>
  # show errors
  console.log "updating error!"
  refreshDataTr sel, new_tr, 'red'
<% else %>
  console.log "update ok."
  refreshDataTr sel, new_tr, 'green'
<% end %>
