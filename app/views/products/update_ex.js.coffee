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

  for id, new_tr of rows
    # replace the modified record
    tr = $("#products-list tr[data-id=#{id}]")
    clazz = tr.attr("class")
    bgColor = tr.css("background-color")
    tr.replaceWith(new_tr)
    tr = $("#products-list tr[data-id=#{id}]").attr("class", clazz)

    # highlight the modified record
    tr.css({'background-color': 'yellow'}).animate({'background-color': bgColor}, 1500)

  # remove the background-color style
  clearStyle = () ->
    for id,_ of rows
      $("#products-list tr[data-id=#{id}]").css({'background-color': ''})
  setTimeout clearStyle, 1501

  console.log "good request, completed!"

<% else %>

  console.log "bad request, no selection!"

<% end %>

