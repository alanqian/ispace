  # replace the modified record
  id = <%= @brand.id %>
  new_tr = "<%=j render partial: 'item', locals: { brand: @brand } %>"
  tr = $("#brands-list tr[data-id=#{id}]")
  bgColor = tr.css("background-color")
  tr.replaceWith(new_tr)
  tr = $("#brands-list tr[data-id=#{id}]")

<% if @brand.errors.any? %>
  # show errors
<% else %>
  # highlight the modified record
  tr.css({'background-color': 'yellow'}).animate({'background-color': bgColor}, 1500)
<% end %>
