  id = "<%= @region.id %>"
  new_tr = "<%=j render partial: 'item', locals: { region: @region, } %>"
  sel = "#regions-list tr[data-id='#{id}']"

<% if @region.errors.any? %>
  # show errors
  console.log "updating error!"
  refreshDataTr sel, new_tr, 'red'
<% else %>
  console.log "update ok."
  refreshDataTr sel, new_tr, 'green'
<% end %>
