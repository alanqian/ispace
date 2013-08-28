  # replace the modified record
  id = <%= @product.id %>
  new_tr = "<%=j render partial: 'item', locals: { product: @product,
    brands_hash: @brands_hash, suppliers_hash: @suppliers_hash, mfrs_hash: @mfrs_hash } %>"
  sel = "#products-list tr[data-id=#{id}]"

<% if @product.errors.any? %>
  # show errors
  console.log "updating error!"
  refreshDataTr sel, new_tr, 'red'
<% else %>
  console.log "update ok."
  refreshDataTr sel, new_tr, 'green'
<% end %>
