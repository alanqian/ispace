  # hide the form div
  $('div#products-setup').hide()

<% if @products.any? %>

  # modify the rows
  rows = {}
  # replace the modified records
  <% @products.each do |id| %>
  rows["<%= id %>"] = "<%=j render partial: 'item', locals: { product: @products_hash[id],
    brands_hash: @brands_hash, suppliers_hash: @suppliers_hash, mfrs_hash: @mfrs_hash } %>"
  <% end %>

  refreshDataTrs "#products-list tr[data-id={id}]", rows, 'green'
  console.log "update ok."

<% else %>

  console.log "bad request, no selection!"

<% end %>

