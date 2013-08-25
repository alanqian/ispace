  # replace the modified record
  id = <%= @product.id %>
  new_tr = "<%=j render partial: 'item', locals: { product: @product,
    brands_hash: @brands_hash, mfrs_hash: @mfrs_hash } %>"
  tr = $("#products-list tr[data-id=#{id}]")
  bgColor = tr.css("background-color")
  tr.replaceWith(new_tr)
  tr = $("#products-list tr[data-id=#{id}]")

<% if @product.errors.any? %>
  # show errors
<% else %>
  # highlight the modified record
  tr.css({'background-color': 'yellow'}).animate({'background-color': bgColor}, 1500)
<% end %>
