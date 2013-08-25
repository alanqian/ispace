  # replace the modified record
  id = <%= @supplier.id %>
  new_tr = "<%=j render partial: 'item', locals: { supplier: @supplier } %>"
  tr = $("#suppliers-list tr[data-id=#{id}]")
  bgColor = tr.css("background-color")
  tr.replaceWith(new_tr)
  tr = $("#suppliers-list tr[data-id=#{id}]")

<% if @supplier.errors.any? %>
  # show errors
<% else %>
  # highlight the modified record
  tr.css({'background-color': 'yellow'}).animate({'background-color': bgColor}, 1500)
<% end %>
